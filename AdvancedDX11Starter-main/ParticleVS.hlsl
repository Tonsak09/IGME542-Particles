#include "AnimCurves.hlsli"

cbuffer externalData : register(b0)
{
    matrix view;
    matrix projection;
    
    float4 startScale;
    float4 targetScale;
    int scaleAnimCurve;
    
    float currentTime;
    float noiseScale;
    float gravity; 
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

VertexToPixel main(uint id : SV_VertexID)
{
	VertexToPixel output;

	// id
    uint particleID = id / 4; // Every group of 4 verts are ONE particle!
    uint cornerID = id % 4; // 0,1,2,3 = the corner of the particle "quad"

    Particle p = Particles.Load(particleID);

    float3 pos = p.startPos; //
    float size = 1.0f;
    output.tint = float4(currentTime, 0.0, 0.0f, 1.0);
	// Offsets for the 4 corners of a quad - we'll only
	// use one for each vertex, but which one depends
	// on the cornerID above.
    float2 offsets[4];
    offsets[0] = float2(-1.0f, +1.0f); // TL
    offsets[1] = float2(+1.0f, +1.0f); // TR
    offsets[2] = float2(+1.0f, -1.0f); // BR
    offsets[3] = float2(-1.0f, -1.0f); // BL
	
    float s, c, rotation = lerp(0.0f, 45.0f, 0.0f);
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
    pos += (false ? float3(0, 1, 0) : float3(view._21, view._22, view._23)) * rotatedOffset.y; // UP

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
