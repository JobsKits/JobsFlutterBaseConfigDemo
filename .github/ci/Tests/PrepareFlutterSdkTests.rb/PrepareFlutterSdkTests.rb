# Created by Jobs. Uses private fake SDK/archives and a fake curl; no real network/build.
# JOBS_TERMINAL_STYLE_GUARD_V1_BEGIN
if $PROGRAM_NAME == __FILE__
  # 直接运行时由 fork 父进程保护配色；子进程继续原文件，不重放 Ruby 参数和预载模块。
  def jobs_terminal_style_bootstrap_v1
    return unless $PROGRAM_NAME == __FILE__
    plain = lambda do
      ENV.update('PLAIN_OUTPUT' => '1', 'NO_COLOR' => '1', 'FORCE_COLOR' => '0',
                 'CLICOLOR' => '0', 'ANSI_COLORS_DISABLED' => '1', 'npm_config_color' => 'false')
    end
    notify = lambda do |message|
      encoding = $stderr.external_encoding || Encoding::UTF_8
      $stderr.write((message + "\n").encode(encoding, invalid: :replace, undef: :replace))
    end
    return unless $stdin.tty? && $stdout.tty?
    return if ENV.key?('NO_COLOR') || ENV['PLAIN_OUTPUT'] == '1' ||
              ENV['IS_SOURCETREE_RUNTIME'] == '1' ||
              ENV.keys.any? { |key| key.match?(/\A(?:SOURCETREE|SOURCE_TREE)/i) }
    return if ['', 'dumb'].include?(ENV.fetch('TERM', ''))
    if File::ALT_SEPARATOR == '\\' || !Process.respond_to?(:fork) ||
       Thread.list.length > 1 || ENV['TMUX'] || ENV['STY']
      plain.call
      return
    end
    tty_name = IO.popen(['tty'], err: File::NULL, &:read).strip
    groups = IO.popen(['ps', '-o', 'pgid=', '-o', 'tpgid=', '-p', Process.pid.to_s], err: File::NULL, &:read).split
    unless tty_name.match?(%r{\A/dev/[A-Za-z0-9_./-]+\z}) && groups.length == 2 &&
           groups.all? { |group| group.match?(/\A\d+\z/) } && groups[0].to_i > 0 && groups[0] == groups[1]
      plain.call
      return
    end
    owner = ENV['JOBS_TERMINAL_STYLE_OWNER']
    if ENV['JOBS_TERMINAL_STYLE_TTY'] == tty_name && owner && owner.match?(/\A\d+\z/)
      begin
        Process.kill(0, owner.to_i)
        return
      rescue Errno::ESRCH, Errno::EPERM
      end
    end
    require 'io/console'
    require 'tmpdir'
    if Thread.list.length > 1
      plain.call
      return
    end
    tty = File.open('/dev/tty', 'r+')
    tty.binmode
    tty.sync = true
    keys = ['10', '11', '12'] + (0..15).map { |index| "4;#{index}" }
    palette = %w[000000 ff5f56 5fd787 ffd75f 5fafff d787ff 5fd7ff eeeeee
                 9e9e9e ff8787 87ffaf ffff87 87bfff ffafff afffff ffffff]
    targets = { '10' => 'ffffff', '11' => '000000', '12' => 'ffffff' }
    palette.each_with_index { |color, index| targets["4;#{index}"] = color }
    query = lambda do |key|
      tty.write("\e]#{key};?\a")
      bytes = ''.b
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 0.3
      loop do
        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        return nil if remaining <= 0 || !IO.select([tty], nil, nil, remaining)
        piece = tty.read_nonblock(256, exception: false)
        next if piece == :wait_readable
        return nil unless piece && !piece.empty?
        bytes << piece
        return nil if bytes.bytesize > 256 || !bytes.start_with?("\e".b)
        break if bytes.end_with?("\a".b) || bytes.end_with?("\e\\".b)
      end
      match = bytes.match(/\A\e\]#{Regexp.escape(key)};rgb:([0-9a-fA-F]{1,4})\/([0-9a-fA-F]{1,4})\/([0-9a-fA-F]{1,4})(?:\a|\e\\)\z/n)
      return nil unless match
      components = match.captures.map { |hex| (hex.to_i(16) * 65535.0 / (16**hex.length - 1)).round }
      { raw: bytes, rgb: components }
    rescue IOError, SystemCallError
      nil
    end
    snapshot = lambda do
      values = {}
      tty.raw(min: 0, time: 0, intr: true) do
        keys.each do |key|
          value = query.call(key)
          return nil unless value
          values[key] = value
        end
      end
      values
    rescue IOError, SystemCallError, ArgumentError
      nil
    end
    original = snapshot.call
    unless original
      notify.call('终端不支持完整配色保存，或启动时收到其它输入；保留原配色并使用纯文本。')
      tty.close
      plain.call
      return
    end
    directory = Dir.mktmpdir('jobs-terminal-style-')
    recovery = File.join(directory, 'restore.sh')
    original_bytes = keys.map { |key| original.fetch(key).fetch(:raw) }.join
    recovery_source = "#!/bin/sh\n" \
      "[ -t 0 ] && [ \"$(tty)\" = '#{tty_name}' ] || { printf '请在原终端运行恢复入口。\\n' >&2; exit 1; }\n" \
      "printf '本操作会覆盖此终端当前配色。确认恢复脚本启动前的配色，请输入 YES：' >&2\n" \
      "IFS= read -r jobs_restore_choice\n[ \"$jobs_restore_choice\" = YES ] || exit 1\n" \
      "printf '%s\\033[0m' '#{original_bytes}' > /dev/tty\n"
    File.open(recovery, File::WRONLY | File::CREAT | File::EXCL, 0o600) do |file|
      file.binmode
      file.write(recovery_source.b)
    end
    notify.call("本次终端临时使用黑底白字；强退后恢复入口：sh \"#{recovery}\"")
    changed = false
    applied = nil
    # 比较仍生效的本轮颜色，只恢复未被用户另行修改的项。
    cleanup = lambda do
      current = applied && snapshot.call
      unless current
        notify.call("终端配色未能安全自动恢复；确认覆盖当前配色后可运行：sh \"#{recovery}\"")
        return false
      end
      conflicts = []
      restore_bytes = ''.b
      keys.each do |key|
        if current.fetch(key).fetch(:rgb) == applied.fetch(key).fetch(:rgb)
          restore_bytes << original.fetch(key).fetch(:raw)
        else
          conflicts << key
        end
      end
      tty.write(restore_bytes + "\e[0m".b)
      if conflicts.empty?
        File.unlink(recovery)
        Dir.rmdir(directory)
        true
      else
        notify.call("检测到运行期间的配色变更，已保留这些项：#{conflicts.join(' ')}")
        notify.call("确认要覆盖后续改色时才使用恢复入口：sh \"#{recovery}\"")
        false
      end
    rescue IOError, SystemCallError
      notify.call("终端配色未能安全自动恢复；确认覆盖当前配色后可运行：sh \"#{recovery}\"")
      false
    end
    child_pid = nil
    guardian = false
    interrupted = nil
    previous_signals = {}
    %w[INT TERM HUP].each do |name|
      previous_signals[name] = Signal.trap(name) do
        interrupted = name
        if child_pid && name != 'INT'
          begin
            Process.kill(name, child_pid)
          rescue Errno::ESRCH
          end
        end
      end
    end
    begin
      changed = true
      tty.write(targets.map { |key, color| "\e]#{key};##{color}\a" }.join + "\e[0m")
      applied = snapshot.call
      unless applied
        notify.call('无法核实本次临时配色，已停止启动业务。')
        raise SystemExit, 1
      end
      desired = targets.all? do |key, hex|
        rgb = hex.scan(/../).map { |component| component.to_i(16) * 257 }
        applied.fetch(key).fetch(:rgb).zip(rgb).all? { |actual, expected| (actual - expected).abs <= 255 }
      end
      unless desired
        notify.call('终端未接受本次配色，恢复后使用纯文本。')
        restored = cleanup.call
        changed = false
        raise SystemExit, 1 unless restored
        plain.call
        return
      end
      if interrupted
        raise SystemExit, 128 + Signal.list.fetch(interrupted)
      end
      if Thread.list.length > 1
        restored = cleanup.call
        changed = false
        raise SystemExit, 1 unless restored
        plain.call
        return
      end
      $stdout.flush
      $stderr.flush
      begin
        child_pid = Process.fork
      rescue NotImplementedError, SystemCallError
        restored = cleanup.call
        changed = false
        raise SystemExit, 1 unless restored
        plain.call
        return
      end
      unless child_pid
        changed = false
        ENV['JOBS_TERMINAL_STYLE_TTY'] = tty_name
        ENV['JOBS_TERMINAL_STYLE_OWNER'] = Process.ppid.to_s
        raise SystemExit, 128 + Signal.list.fetch(interrupted) if interrupted
        return
      end
      guardian = true
      result = nil
      loop do
        begin
          _, result = Process.wait2(child_pid)
          break
        rescue Interrupt, Errno::EINTR
        end
      end
      status_code = result.exitstatus || 128 + result.termsig
      %w[INT TERM HUP].each { |name| Signal.trap(name, 'IGNORE') }
      restored = cleanup.call
      changed = false
      status_code = 1 if !restored && status_code.zero?
      tty.close
      Process.exit!(status_code)
    ensure
      if changed
        %w[INT TERM HUP].each { |name| Signal.trap(name, 'IGNORE') }
        cleanup.call
      end
      previous_signals.each { |name, handler| Signal.trap(name, handler) } unless guardian
      tty.close unless tty.closed?
    end
  rescue IOError, SystemCallError, LoadError => error
    if guardian
      notify.call("终端保护监督进程异常：#{error.message}")
      Process.exit!(1)
    end
    raise SystemExit, 1 if changed
    notify.call("终端保护不可用，使用纯文本：#{error.message}")
    plain.call
  end
  jobs_terminal_style_bootstrap_v1

end
# JOBS_TERMINAL_STYLE_GUARD_V1_END

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
