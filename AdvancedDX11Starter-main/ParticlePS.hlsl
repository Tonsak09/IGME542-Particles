struct VertexToPixel
{
	float4 pos : SV_POSITION; // The world position of this PIXEL
	float2 uv : TEXCOORD;
};

Texture2D Particle : register(t0);
SamplerState BasicSampler : register(s0);

float4 main(VertexToPixel input) : SV_TARGET
{
	return float4(1.0f, 0.0f, 0.0f, 1.0f);
}