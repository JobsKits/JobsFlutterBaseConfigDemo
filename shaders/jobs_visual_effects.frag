#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uSize;
uniform float uTime;
uniform vec2 uCenter;
uniform float uStrength;
uniform float uRadius;
uniform float uProgress;
uniform float uMode;
uniform float uDark;
uniform sampler2D uTexture;
out vec4 fragColor;

// 独立实现的纹理坐标实验：每种模式都改变实际采样位置或颜色。
void main() {
  vec2 uv = FlutterFragCoord().xy / max(uSize, vec2(1.0));
  vec2 delta = uv - uCenter;
  float aspect = uSize.x / max(uSize.y, 1.0);
  vec2 radial = delta * vec2(aspect, 1.0);
  float distance = length(radial);
  vec2 direction = delta / max(distance, 0.001);
  float radius = max(uRadius, 0.03);
  float inside = 1.0 - smoothstep(radius * 0.88, radius, distance);
  vec2 sampleUV = uv;
  if (uMode < 0.5) {
    float curvature = sqrt(max(0.0, 1.0 - pow(min(distance / radius, 1.0), 2.0)));
    sampleUV -= delta * curvature * inside * uStrength * 0.48;
  } else if (uMode < 1.5) {
    float travel = fract(uTime * 0.24) * radius * 2.0;
    float wave = sin((distance - travel) * 65.0);
    float envelope = exp(-pow((distance - travel) / max(radius * 0.28, 0.01), 2.0));
    sampleUV += direction * wave * envelope * uStrength * 0.034;
  } else if (uMode < 2.5) {
    float pulse = sin(uTime * 3.3) * uStrength;
    sampleUV -= delta * exp(-distance * distance / (radius * radius)) * pulse * 0.6;
  } else {
    float sweep = uCenter.y + radius * 0.7 * sin(uTime * 0.8);
    float scan = 1.0 - smoothstep(radius * 0.15, radius, abs(uv.y - sweep));
    float block = 1.0 + 42.0 * uStrength * scan;
    vec2 cells = max(uSize / block, vec2(1.0));
    vec2 quantized = (floor((uv - uCenter) * cells) + 0.5) / cells + uCenter;
    sampleUV = mix(uv, quantized, uStrength * scan);
  }
  vec4 color = texture(uTexture, clamp(sampleUV, 0.001, 0.999));
  if (uMode < 0.5) {
    float rim = inside * smoothstep(radius * 0.72, radius * 0.96, distance);
    color.rgb = mix(color.rgb, vec3(0.92, 0.98, 1.0), rim * uStrength * 0.65);
  }
  // 手动进度影响混合强度；降低动态效果时仍可检查相同纹理管线。
  vec4 original = texture(uTexture, clamp(uv, 0.001, 0.999));
  color = mix(original, color, clamp(uProgress, 0.0, 1.0));
  color.rgb *= 1.0 - uDark * 0.015;
  fragColor = color;
}
