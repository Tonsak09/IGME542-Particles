
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

    float total = 0.0f; 
    for (int i = 0; i < 3; i++)
    {
        float2 ballCenter = balls[i].pos;
        float distance = length(pixelPos - ballCenter) - balls[i].radius;

        total += (distance < 0.0f) ? 1.0f : pow( balls[i].radius / distance, 2.0f);
    }

    total = clamp(total, 0, 1);

    // Inverse lerp 
    float4 color = float4(total, total, total, 1.0);
    
    outputTexture[DTid.xy] = color;
    
}