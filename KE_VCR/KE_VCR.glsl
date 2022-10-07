// Created by ryk in 2014-02-02 - https://www.shadertoy.com/view/ldjGzV

// Ported to Flame Matchbox by Ted Stanley (KuleshovEffect) - September, 2022
// v1.0 

uniform sampler2D back, front;
uniform float adsk_back_w, adsk_back_h;
uniform float adsk_result_w, adsk_result_h;
uniform float adsk_time;

uniform int numstripes, stripespeed, vigamount, noiseamount, shakes, shaketime, shakewave, vertshift, frequency;

float noise(vec2 p)
{
	vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
	float iTime = adsk_time / 24.0;
	
	float s = texture2D(back,vec2(1.,2.*cos(iTime))*iTime*8. + p*1.).x;
	s *= s;
	return s;
}

float onOff(float a, float b, float c)
{
	vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
	float iTime = adsk_time / 24.0;
	
	float onoffvalue = step(c, sin(iTime + a*cos(iTime*b)));
	float freq = float(frequency);
    return onoffvalue * freq / 100.0;
}

float ramp(float y, float start, float end)
{
	float inside = step(start,y) - step(end,y);
	float fact = (y-start)/(end-start)*inside;
	return (1.-fact) * inside;
	
}

float stripes(vec2 uv)
{
	
	vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
	float iTime = adsk_time / 24.0;
	
	float noi = noise(uv*vec2(0.5,1.) + vec2(1.,3.));
	float stripespeedf = float(stripespeed);
	return ramp(mod(uv.y*(float(numstripes)) + iTime/(stripespeedf / 10.0)+sin(iTime + sin(iTime*0.63)),1.),0.5,0.6)*noi; 
}

vec3 getVideo(vec2 uv)
{
	vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
	float iTime = adsk_time / 24.0;
	
	vec2 look = uv;
	float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
	look.x = look.x + sin(look.y*float(shakes) + iTime)/float(shaketime)*onOff(4.,4.,.3)*(1.+cos(iTime*float(shakewave)))*window;
	float vertshiftf = float(vertshift);
	float vShift = (vertshiftf / 100.0)*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) + 
										 (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
	look.y = mod(look.y + vShift, 1.);
	vec3 video = vec3(texture2D(front,look));
	return video;
}

vec2 screenDistort(vec2 uv)
{
	uv -= vec2(.5,.5);
	uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
	uv += vec2(.5,.5);
	return uv;
}

void main( void )
{
	vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
	float iTime = adsk_time / 24.0;
	
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	uv = screenDistort(uv);
	vec3 video = getVideo(uv);
	float vigAmt = float(vigamount)+.3*sin(iTime + 5.*cos(iTime*5.));
	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
	
	video += stripes(uv);
	//video += noise(uv*(float(noiseamount)))/2.;
    video += texture2D(back,uv).rgb / float(noiseamount);
	video *= vignette;
	video *= (12.+mod(uv.y*30.+iTime,1.))/13.;
	
	gl_FragColor = vec4(video,1.0);
}