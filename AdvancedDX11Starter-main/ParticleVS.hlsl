cbuffer externalData : register(b0)
{
    matrix view;
    matrix projection;
    float currentTime;
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
};

StructuredBuffer<Particle> Particles : register(t0);

VertexToPixel main(uint id : SV_VertexID)
{
	VertexToPixel output;

	// Get id info
    uint particleID = id / 4; // Every group of 4 verts are ONE particle!
    uint cornerID = id % 4; // 0,1,2,3 = the corner of the particle "quad"

	// Grab one particle and its starting position
    Particle p = Particles.Load(particleID);

	// Constant accleration function to determine the particle's
	// current location based on age, start velocity and accel
    float3 pos = float3(0, 0, 0);

	// Size interpolation
    float size = 1.0f;

	// Offsets for the 4 corners of a quad - we'll only
	// use one for each vertex, but which one depends
	// on the cornerID above.
    float2 offsets[4];
    offsets[0] = float2(-1.0f, +1.0f); // TL
    offsets[1] = float2(+1.0f, +1.0f); // TR
    offsets[2] = float2(+1.0f, -1.0f); // BR
    offsets[3] = float2(-1.0f, -1.0f); // BL
	
	//// Handle rotation - get sin/cos and build a rotation matrix
    float s, c, rotation = lerp(0.0f, 45.0f, 0.0f);
    sincos(rotation, s, c); // One function to calc both sin and cos
    float2x2 rot =
    {
        c, s,
		-s, c
    };

	// Rotate the offset for this corner and apply size
    float2 rotatedOffset = mul(offsets[cornerID], rot) * size;

	// Billboarding!
	// Offset the position based on the camera's right and up vectors
    pos += float3(view._11, view._12, view._13) * rotatedOffset.x; // RIGHT
    pos += (false ? float3(0, 1, 0) : float3(view._21, view._22, view._23)) * rotatedOffset.y; // UP

    //pos += float3(offsets[cornerID], 0.0f); // RIGHT


	// Calculate output position
    matrix viewProj = mul(projection, view);
    output.pos = mul(viewProj, float4(pos, 1.0f));

    // Get the U/V indices (basically column & row index across the sprite sheet)
    uint uIndex = 0;
    uint vIndex = 1; // Integer division is important here!

    // Convert to a top-left corner in uv space (0-1)
    float u = uIndex / (float)1;
    float v = vIndex / (float)1;

    float spriteSheetFrameWidth = 1.0f;
    float spriteSheetFrameHeight = 1.0f;

    float2 uvs[4];
    /* TL */ uvs[0] = float2(u, v);
    /* TR */ uvs[1] = float2(u + spriteSheetFrameWidth, v);
    /* BR */ uvs[2] = float2(u + spriteSheetFrameWidth, v + spriteSheetFrameHeight);
    /* BL */ uvs[3] = float2(u, v + spriteSheetFrameHeight);

    // Finalize output
    output.uv = saturate(uvs[cornerID]);

	return output;
}

/*
void alt()
{
	// id
    uint particleID = id / 4; // Every 4 verts are ONE particle!
    uint cornerID = id % 4; // 0,1,2,3 = which corner of the "quad"
	
    Particle p = Particles.Load(particleID);
	
    // Set up position 
    float2 offsets[4];
    offsets[0] = float2(-1.0f, +1.0f); // Top Left
    offsets[1] = float2(+1.0f, +1.0f); // Top Right
    offsets[2] = float2(+1.0f, -1.0f); // Bottom Right
    offsets[3] = float2(-1.0f, -1.0f); // Bottom Left
    
    
    float3 pos = float3(0, 0, 0) + float3(offsets[cornerID], 0);
    
    matrix viewProj = mul(projection, view);
    output.pos = mul(viewProj, float4(pos, 1.0f));
    
    // Set up UVs
    float2 uvs[4];
    uvs[0] = float2(0, 0); // TL
    uvs[1] = float2(1, 0); // TR
    uvs[2] = float2(1, 1); // BR
    uvs[3] = float2(0, 1); // BL
    output.uv = uvs[cornerID];
}*/