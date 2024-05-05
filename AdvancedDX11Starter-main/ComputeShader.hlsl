
struct MetalBall
{
    float3 color;
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

    float3 black = float3(0.0f, 0.0f, 0.0f);
    float3 influence = float3(0,0,0); 
    for (int i = 0; i < 3; i++)
    {
        float2 ballCenter = balls[i].pos;

        float distance = length(pixelPos - ballCenter);
        float isInRange = distance - balls[i].radius;

        float lerpActive = (isInRange < 0.0f) ? 1.0f : clamp(pow(balls[i].radius / distance, 2.0f), 0, 1);

        influence[i] += lerpActive;
    }

    // Inverse lerp 
    if (length(influence) >= 0.8f)
    {
        outputTexture[DTid.xy] = float4(normalize(influence), 1.0);
    }
    else
    {
        outputTexture[DTid.xy] = float4(black, 1.0f);
    }
    
}