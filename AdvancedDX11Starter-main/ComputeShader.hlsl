
struct MetalBall
{
    float2 pos;
    float radius;
};


RWTexture2D<unorm float4> outputTexture : register(u0);
StructuredBuffer<MetalBall> balls : register(t0);

float InverseLerp(float a, float b, float x)
{
    return saturate((x - a) / (b - a));
}



[numthreads(8, 8, 1)] // Not sure why 8 is better 
void main( uint3 DTid : SV_DispatchThreadID )
{
    float2 pixelPos = float2(DTid.x, DTid.y);
    
    float2 ballCenter = balls[0].pos;
    float distance = length(pixelPos - ballCenter) - balls[0].radius;
    
    // Inverse lerp 
    
    outputTexture[DTid.xy] = float4(distance, distance, distance, 1.0f);
    
}