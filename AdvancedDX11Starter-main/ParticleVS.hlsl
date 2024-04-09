struct Particle
{
	float emitTime;
	float3 startPos;
};

struct VertexToPixel
{
	float2 uv  : TEXCOORD;
	float3 pos : POSITION; // The world position of this PIXEL
};

VertexToPixel main(uint id : SV_VertexID)
{
	VertexToPixel output;

	return output;
}