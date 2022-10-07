// created by florian berger (flockaroo) - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// trying to resemble some hand drawing style

// Ported to Flame Matchbox by Ted Stanley (KuleshovEffect) - September, 2022
// v1.0


uniform sampler2D back, front;
uniform float adsk_front_w, adsk_front_h, adsk_back_w, adsk_back_h;
uniform float adsk_result_w, adsk_result_h;
uniform float adsk_time;
uniform int angles, samples, sway, lineblur;
uniform vec3 linecolor;
uniform float boxsize;



#define iResolution Res0



#define randSamp back
#define colorSamp front
#define iTime adsk_time/24.0



vec4 getRand(vec2 pos)
{
    vec2 Res = vec2(adsk_result_w, adsk_result_h);
    vec2 Res1 = vec2(adsk_front_w, adsk_front_h);
    vec2 Res0 = vec2(adsk_back_w, adsk_back_h);

    //return textureLod(back,pos/Res1/iResolution.y*1080., 0.0);
    return texture2D(back,pos/Res1/iResolution.y*1080., 0.0);
}

vec4 getCol(vec2 pos)
{
    // take aspect ratio into account
    vec2 Res = vec2(adsk_result_w, adsk_result_h);
    vec2 Res1 = vec2(adsk_front_w, adsk_front_h);
    vec2 Res0 = vec2(adsk_back_w, adsk_back_h);
    vec2 uv=((pos-Res.xy*.5)/Res.y*Res0.y)/Res0.xy+.5;
    vec4 c1=texture2D(front,uv);
    vec4 e=smoothstep(vec4(-0.05),vec4(-0.0),vec4(uv,vec2(1)-uv));
    c1=mix(vec4(1,1,1,0),c1,e.x*e.y*e.z*e.w);
    float d=clamp(dot(c1.xyz,vec3(-.5,1.,-.5)),0.0,1.0);
    vec4 c2=vec4(.7);
    return min(mix(c1,c2,1.8*d),.7);
}

vec4 getColHT(vec2 pos)
{
 	return smoothstep(.95,1.05,getCol(pos)*.8+.2+getRand(pos*.7));
}

float getVal(vec2 pos)
{
    vec4 c=getCol(pos);
 	return pow(dot(c.xyz,vec3(.333)),1.)*1.;
}

vec2 getGrad(vec2 pos, float eps)
{
   	vec2 d=vec2(eps,0);
    return vec2(
        getVal(pos+d.xy)-getVal(pos-d.xy),
        getVal(pos+d.yx)-getVal(pos-d.yx)
    )/eps/2.;
}

#define AngleNum angles

#define SampNum samples
#define PI2 6.28318530717959



void main(void)
{
    
    vec2 Res = vec2(adsk_result_w, adsk_result_h);
    vec2 Res1 = vec2(adsk_front_w, adsk_front_h);
    vec2 Res0 = vec2(adsk_back_w, adsk_back_h);
    
    vec2 pos = vec2(gl_FragCoord.xy+float(sway)*sin(iTime*1.*vec2(1,1.7))*iResolution.y/400.);
    vec3 col = vec3(0);
    vec3 col2 = vec3(0);
    float sum=0.;
    for(int i=0;i<AngleNum;i++)
    {
        float ang=PI2/float(AngleNum)*(float(i)+.8);
        vec2 v=vec2(cos(ang),sin(ang));
        for(int j=0;j<SampNum;j++)
        {
            vec2 dpos  = v.yx*vec2(1,-1)*float(j)*iResolution.y/400.;
            vec2 dpos2 = v.xy*float(j*j)/float(SampNum)*.5*iResolution.y/400.;
	        vec2 g;
            float fact;
            float fact2;

            for(float s=-1.;s<=1.;s+=2.)
            {
                vec2 pos2=pos+s*dpos+dpos2;
                vec2 pos3=pos+(s*dpos+dpos2).yx*vec2(1,-1)*2.;
            	g=getGrad(pos2,.4);
            	fact=dot(g,v)-.5*abs(dot(g,v.yx*vec2(1,-1)))/**(1.-getVal(pos2))*/;
            	fact2=dot(normalize(g+vec2(.0001)),v.yx*vec2(1,-1));
                
                fact=clamp(fact,0.,.05);
                fact2=abs(fact2);
                
                fact*=1.-float(j)/float(SampNum);
            	col += fact;
            	col2 += fact2*getColHT(pos3).xyz;
            	sum+=fact2;
            }
        }
    }
    col/=float(SampNum*AngleNum)*.75/sqrt(iResolution.y);
    col2/=sum;
    col.x*=(.6+.8*getRand(pos*.7).x);
    col.x=1.-col.x;
    col.x*=col.x*col.x;

    vec2 s=sin(pos.xy*boxsize/sqrt(iResolution.y/400.));
    vec3 karo=vec3(1);
    //karo-=.5*vec3(.25,.1,.1)*dot(exp(-s*s*80.),vec2(1));
    karo-=.5*vec3(linecolor)*dot(exp(-s*s*float(lineblur)),vec2(1));
    float r=length(pos-iResolution.xy*.5)/iResolution.x;
    float vign=1.-r*r*r;
	gl_FragColor = vec4(vec3(col.x*col2*karo*vign),1.0);

 
}
