// Created by rmmcal in 2019-11-02 - https://www.shadertoy.com/view/wdtSRl

// Ported to Flame Matchbox by Ted Stanley (KuleshovEffect) - September, 2022
// v1.0 

uniform sampler2D back, front;
uniform float adsk_back_w, adsk_back_h;
uniform float adsk_result_w, adsk_result_h;

uniform int transparency;

void main( void )
{
	vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
	float trans = float(transparency);
	trans = trans / 100.0;
	//float trans = float(transparency / 100);
	vec2 p = gl_FragCoord.xy / iResolution.xy;
	gl_FragColor = texture2D(back, p+(texture2D(front, p).rb-vec2(0.0471, 0.1451))*trans);
}