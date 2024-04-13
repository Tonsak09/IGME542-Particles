#include "AnimCurves.hlsli"

cbuffer externalData : register(b0)
{
    matrix view;
    matrix projection;
    
    float4 startScale;
    float4 targetScale;
    float4 startColor;
    float4 targetColor;
    float startRot;
    float targetRot;
    
    float currentTime;

    float noiseScale;
    float gravity;
    float pLifetime;

    int scaleAnimCurve;
    int colorAnimCurve;

};

struct Particle
{
	float emitTime;
	float3 startPos;
};

struct VertexToPixel
{
	float4 pos : SV_POSITION; // The world position of this PIXEL
	float2 uv  : TEXCOORD;
    float4 tint : COLOR;
};

StructuredBuffer<Particle> Particles : register(t0);

// Noise from: https://gist.github.com/h3r/3a92295517b2bee8a82c1de1456431dc
float rand1(float n) { return frac(sin(n) * 43758.5453123); }
float gnoise(float p) {
    float fl = floor(p);
    float fc = frac(p);
    return lerp(rand1(fl), rand1(fl + 1.0), fc);
}

VertexToPixel main(uint id : SV_VertexID)
{
	VertexToPixel output;

	// id
    uint particleID = id / 4; // Every group of 4 verts are ONE particle!
    uint cornerID = id % 4; // 0,1,2,3 = the corner of the particle "quad"

    Particle p = Particles.Load(particleID);
    float time = (currentTime - p.emitTime);
    float pLerp = time / pLifetime;

    // SUVAT calculation 
    float3 pos = p.startPos + float3(0.0f, 1.0f, 0.0f) * (0.5f * gravity * time * time);
    pos += gnoise(time * 10.0f) * noiseScale;

    float size = lerp(startScale, targetScale, GetCurveByIndex(scaleAnimCurve, pLerp));
    output.tint = lerp(startColor, targetColor, GetCurveByIndex(colorAnimCurve, pLerp));

    float2 offsets[4];
    offsets[0] = float2(-1.0f, +1.0f); // TL
    offsets[1] = float2(+1.0f, +1.0f); // TR
    offsets[2] = float2(+1.0f, -1.0f); // BR
    offsets[3] = float2(-1.0f, -1.0f); // BL
	
    float s, c, rotation = lerp(startRot, targetRot, pLerp);
    sincos(rotation, s, c); // One function to calc both sin and cos
    float2x2 rot =
    {
        c, s,
		-s, c
    };

	// Using 0,0 as the origin we rotate each corner around that then 
    // include the size scaler 
    float2 rotatedOffset = mul(offsets[cornerID], rot) * size;

	// Fancy billboarding equation that Prof supplied 
    pos += float3(view._11, view._12, view._13) * rotatedOffset.x; // RIGHT
    pos += float3(view._21, view._22, view._23) * rotatedOffset.y; // UP

	// Send position into camera space 
    matrix viewProj = mul(projection, view);
    output.pos = mul(viewProj, float4(pos, 1.0f));

    float2 uvs[4];
    uvs[0] = float2(0, 0); // TL
    uvs[1] = float2(1, 0); // TR
    uvs[2] = float2(1, 1); // BR
    uvs[3] = float2(0, 1); // BL
    output.uv = uvs[cornerID];

	return output;
}
