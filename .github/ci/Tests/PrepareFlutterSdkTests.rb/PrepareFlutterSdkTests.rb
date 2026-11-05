# Created by Jobs. Uses private fake SDK/archives and a fake curl; no real network/build.
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'shellwords'
require 'json'
require 'digest'
require 'base64'
require 'timeout'
require 'yaml'

class PrepareFlutterSdkTests < Minitest::Test
  CI = File.expand_path('../..', __dir__)
  INSTALLER = File.join(CI, '【MacOS】PrepareFlutterSdk.zsh/【MacOS】PrepareFlutterSdk.zsh')
  CLEAR = %w[FLUTTER_STORAGE_BASE_URL PUB_HOSTED_URL HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy NO_PROXY no_proxy FLUTTER_REALM FLUTTER_PREBUILT_ENGINE_VERSION JOBS_FLUTTER_ROUTE_CACHE_DIR CURL_HOME XDG_CONFIG_HOME].freeze
  def setup
    @tmp=Dir.mktmpdir('jobs-ci-sdk-test-'); @runner=File.join(@tmp,'runner'); @sdk=File.join(@tmp,'source/flutter'); @log=File.join(@tmp,'logs')
    FileUtils.mkdir_p([@runner,@log,File.join(@sdk,'bin/cache/dart-sdk/bin'),File.join(@sdk,'bin/internal')])
    value,=Open3.capture2('/usr/sbin/sysctl','-n','hw.optional.arm64');@arch=value.strip=='1' ? 'arm64' : 'x64'
    flutter=<<~'SH'
      #!/bin/zsh
      action="$1"; count=0; file="$FIXTURE_ROOT/$action.count"
      [[ ! -f "$file" ]] || count=$(<"$file"); (( count++ )); print "$count" > "$file"
      case "$action" in
        --version)
          if [[ "${FIXTURE_VERSION_FAIL:-0}" == 1 && "$count" == 1 ]]; then print 'Failed to download SDK'; exit 0; fi
          print '{"frameworkVersion":"3.47.7","engineRevision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}' ;;
        precache) if [[ "${FIXTURE_PRECACHE_FAIL:-0}" == 1 && "$count" == 1 ]]; then print -u2 'Failed to download SDK'; exit 28; fi ;;
        build) exit 7 ;;
      esac
    SH
    File.write(File.join(@sdk,'bin/flutter'),flutter);File.chmod(0o700,File.join(@sdk,'bin/flutter'))
    File.write(File.join(@sdk,'bin/cache/dart-sdk/bin/dart'),"#!/bin/zsh\nexit 0\n");File.chmod(0o700,File.join(@sdk,'bin/cache/dart-sdk/bin/dart'))
    File.write(File.join(@sdk,'bin/internal/engine.version'),'a'*40);File.write(File.join(@sdk,'bin/cache/engine-dart-sdk.stamp'),'a'*40)
    File.binwrite(File.join(@sdk,'payload'),('a'..'z').to_a.join*512)
    @zip=File.join(@tmp,'sdk.zip');_,err,status=Open3.capture3('/usr/bin/zip','-0','-q','-r',@zip,'flutter',chdir:File.dirname(@sdk));raise err unless status.success?
    @sha=Digest::SHA256.file(@zip).hexdigest; @archive="stable/macos/flutter_macos_#{@arch}_3.47.7-stable.zip"
    File.write(File.join(@tmp,'releases.json'),JSON.generate(base_url:'https://storage.googleapis.com/flutter_infra_release/releases',current_release:{stable:'b'*40},releases:[{version:'3.47.7',hash:'b'*40,dart_sdk_arch:@arch,archive:@archive,sha256:@sha}]))
    File.write(File.join(@tmp,'metadata.json'),JSON.generate(name:"releases/#{@archive}",size:File.size(@zip).to_s,md5Hash:Base64.strict_encode64(Digest::MD5.file(@zip).digest)))
    @curl=File.join(@tmp,'curl')
    File.write(@curl,<<~'SH')
      #!/bin/zsh
      output='' headers='' url='' range=0 resume=0
      while (( $# )); do
        case "$1" in
          --output) output="$2"; shift 2 ;;
          --dump-header) headers="$2"; shift 2 ;;
          --range) range=1; shift 2 ;;
          --continue-at) resume=1; shift 2 ;;
          --write-out|--proxy|--proto|--proto-redir|--max-filesize|--header|--connect-timeout|--max-time|--max-redirs|--speed-time|--speed-limit|--retry|--config) shift 2 ;;
          http*) url="$1"; shift ;;
          *) shift ;;
        esac
      done
      print -r -- "$range|$resume|$url" >> "$FIXTURE_ROOT/curl.calls"
      if [[ "$url" == *releases_macos.json* ]]; then /bin/cp "$FIXTURE_ROOT/releases.json" "$output"; exit 0; fi
      if [[ "$url" == *storage/v1/* ]]; then /bin/cp "$FIXTURE_ROOT/metadata.json" "$output"; exit 0; fi
      if (( range )); then
        /bin/cp "$FIXTURE_ROOT/sdk.zip" "$output"; total=$(/usr/bin/wc -c < "$output"); total=$((total)); etag=$(/sbin/md5 -q "$output")
        printf 'HTTP/1.1 206 Partial Content\r\nContent-Range: bytes 0-%s/%s\r\nETag: "%s"\r\n\r\n' "$((total-1))" "$total" "$etag" > "$headers"
        if [[ "$url" == *storage.flutter-io.cn* ]]; then printf '206\t0.01\t2000000\t0.02'; else printf '206\t0.05\t1000000\t0.10'; fi
        exit 0
      fi
      count=0; [[ ! -f "$FIXTURE_ROOT/download.count" ]] || count=$(<"$FIXTURE_ROOT/download.count"); (( count++ )); print "$count" > "$FIXTURE_ROOT/download.count"
      if [[ "${FIXTURE_DOWNLOAD_FAIL:-0}" == 1 && "$count" == 1 ]]; then /bin/dd if="$FIXTURE_ROOT/sdk.zip" of="$output" bs=1 count=5000 2>/dev/null; exit 28; fi
      if [[ "${FIXTURE_BAD_SHA:-0}" == 1 && "$count" == 1 ]]; then print 'corrupt archive' > "$output"; exit 0; fi
      /bin/cp "$FIXTURE_ROOT/sdk.zip" "$output"
    SH
    File.chmod(0o700,@curl)
  end
  def teardown; FileUtils.remove_entry(@tmp); end
  def env(extra={})
    CLEAR.to_h{|k|[k,nil]}.merge('HOME'=>@tmp,'TMPDIR'=>@tmp+'/','RUNNER_TEMP'=>@runner,'GITHUB_ACTIONS'=>'true','GITHUB_PATH'=>File.join(@tmp,'github-path'),'GITHUB_ENV'=>File.join(@tmp,'github-env'),'JOBS_CI_LOG_DIR'=>@log,'JOBS_FLUTTER_ROUTE_CURL'=>@curl,'FIXTURE_ROOT'=>@tmp).merge(extra)
  end
  def run_code(body,extra={})
    Open3.popen3(env(extra),'/bin/zsh','-f','-c',body) do |input,output,errors,worker|
      input.close
      out=Thread.new{output.read};err=Thread.new{errors.read}
      begin
        status=Timeout.timeout(15){worker.value}
        [out.value,err.value,status]
      rescue Timeout::Error
        Process.kill('TERM',worker.pid) rescue nil
        Timeout.timeout(3){worker.value} rescue nil
        raise "Fixture timeout: #{err.value[-6000..-1] || err.value}"
      ensure
        Process.kill('KILL',worker.pid) if worker.alive?
      end
    end
  end
  def install(extra={})
    run_code("/bin/zsh #{INSTALLER.shellescape} --install 3.47.7 #{@arch}",extra)
  end
  def test_partial_transfer_resumes_and_only_verified_sdk_is_published_and_reused
    out,err,status=install('FIXTURE_DOWNLOAD_FAIL'=>'1');assert status.success?,err+out
    assert_equal '2',File.read(File.join(@tmp,'download.count')).strip
    assert File.readlines(File.join(@tmp,'curl.calls')).any?{|l|l.start_with?('0|1|')},'same SHA partial was not resumed'
    sdk=File.read(File.join(@tmp,'github-path')).strip.sub(%r{/bin$},'')
    assert sdk.start_with?(File.realpath(@runner)+'/jobs-flutter-sdk/3.47.7-'+@arch+'-'+@sha)
    assert File.executable?(File.join(sdk,'bin/flutter'));assert File.executable?(File.join(sdk,'bin/cache/dart-sdk/bin/dart'))
    assert_includes File.read(File.join(sdk,'.jobs-ci-trusted')),@sha
    assert_includes File.read(File.join(@tmp,'github-env')),"FLUTTER_ROOT=#{sdk}"
    assert_includes File.read(File.join(@log,'sdk-download.log')),'原60分钟预算'
    _,again,status=install;assert status.success?,again
    assert_equal '2',File.read(File.join(@tmp,'download.count')).strip,'trusted same SHA SDK should not be re-downloaded'
  end
  def test_bad_sha_is_retained_and_fetch_retries_before_atomic_publication
    out,err,status=install('FIXTURE_BAD_SHA'=>'1');assert status.success?,err+out
    assert_equal '2',File.read(File.join(@tmp,'download.count')).strip
    assert_equal 1,Dir.glob(File.join(@runner,'JobsCiFlutterSdk.*/archive.part.bad-sha.*')).length
    assert_includes File.read(File.join(@log,'sdk-download.log')),'完整SHA校验失败'
  end
  def test_machine_json_is_published_only_after_successful_bootstrap
    destination=File.join(@tmp,'version.json')
    out,err,status=run_code("source #{INSTALLER.shellescape}; jobs_ci_capture_version #{File.join(@sdk,'bin/flutter').shellescape} #{destination.shellescape} #{File.join(@log,'version.log').shellescape}",'FIXTURE_VERSION_FAIL'=>'1')
    assert status.success?,err+out
    assert_equal '',out
    assert_equal '3.47.7',JSON.parse(File.read(destination))['frameworkVersion']
    assert_equal '2',File.read(File.join(@tmp,'--version.count')).strip
    refute_includes File.read(destination),'Failed to download'
  end
  def test_ios_sdk_retries_and_business_build_runs_once
    verification=File.read(File.join(CI,'verify.zsh')).sub(/\nmain "\$@"\s*\z/,"\n")
    library=File.join(@tmp,'verify-library.zsh');File.write(library,verification)
    body="set -euo pipefail; source #{library.shellescape}; source #{INSTALLER.shellescape}; PROJECT_ROOT=#{@tmp.shellescape}; LOG_DIR=#{@log.shellescape}; verify_toolchain(){ return 0; }; verify_simulator_app(){ return 0; }; build_ios"
    out,err,status=run_code(body,'PATH'=>File.join(@sdk,'bin')+':'+ENV.fetch('PATH'),'FIXTURE_PRECACHE_FAIL'=>'1')
    assert_equal 7,status.exitstatus,err+out
    assert_equal '2',File.read(File.join(@tmp,'precache.count')).strip
    assert_equal '1',File.read(File.join(@tmp,'build.count')).strip
  end
  def test_other_architecture_is_rejected_before_any_network_request
    other=@arch=='arm64' ? 'x64' : 'arm64'
    out,err,status=run_code("/bin/zsh #{INSTALLER.shellescape} --install 3.47.7 #{other}")
    assert_equal 2,status.exitstatus,err+out
    refute File.exist?(File.join(@tmp,'curl.calls'))
    refute File.exist?(File.join(@tmp,'github-path'))
  end
  def test_published_parent_symlink_is_rejected_without_sdk_download
    outside=File.join(@tmp,'outside');FileUtils.mkdir_p(outside)
    File.symlink(outside,File.join(@runner,'jobs-flutter-sdk'))
    out,err,status=install
    assert_equal 2,status.exitstatus,err+out
    refute File.exist?(File.join(@tmp,'download.count'))
    assert_empty Dir.children(outside)
  end
  def test_dangling_sdk_target_is_rejected_without_following_or_overwriting
    published=File.join(@runner,'jobs-flutter-sdk');FileUtils.mkdir_p(published);File.write(File.join(published,'.jobs-ci-sdk-root'),'jobs-ci-sdk-v1')
    target=File.join(published,"3.47.7-#{@arch}-#{@sha}");outside=File.join(@tmp,'not-created')
    File.symlink(outside,target)
    out,err,status=install
    assert_equal 2,status.exitstatus,err+out
    assert File.symlink?(target)
    refute File.exist?(outside)
    refute File.exist?(File.join(@tmp,'download.count'))
  end
  def test_installer_does_not_infer_an_unrelated_sdk_from_working_directory
    FileUtils.mkdir_p(File.join(@tmp,'.fvm'))
    File.symlink(@sdk,File.join(@tmp,'.fvm/flutter_sdk'))
    out,err,status=run_code("cd #{@tmp.shellescape}; /bin/zsh #{INSTALLER.shellescape} --install 3.47.7 #{@arch}")
    assert status.success?,err+out
    assert_includes File.read(File.join(@tmp,'curl.calls')),'/releases/stable/macos/'
    refute_includes File.read(File.join(@tmp,'curl.calls')),('/flutter/'+('a'*40))
  end
  def test_workflow_keeps_version_architecture_and_job_budget_without_upstream_source_changes
    workflow=YAML.load_file(File.join(CI,'../workflows/flutter-window-layout.yml'))
    job=workflow.fetch('jobs').fetch('layout-and-ios')
    assert_equal 'xcode-27',job['runs-on'];assert_equal 60,job['timeout-minutes']
    command=job['steps'].find{|step|step['name'].include?('validated network routes')}.fetch('run')
    assert_includes command,'--install 3.47.7 arm64'
    refute job['steps'].any?{|step|step.fetch('uses','').include?('subosito/flutter-action')}
    assert_includes File.read(INSTALLER),'JOBS_FLUTTER_ROUTE_MODE=archive'
  end
end
