
struct MetalBall
{
    float2 pos;
    float radius;
};


RWTexture2D<unorm float4> outputTexture : register(u0);
StructuredBuffer<MetalBall> balls : register(t0);


[numthreads(8, 8, 1)] // Not sure why 8 is better 
void main( uint3 DTid : SV_DispatchThreadID )
{
    float2 pixelPos = float2(DTid.x, DTid.y);
    
    float2 ballCenter = balls[0].pos;
    float distance = length(pixelPos - ballCenter) - balls[0].radius;
    
    
    // Get signed distance 
    float dis = balls[0].radius / (DTid.xy - balls[0].pos);
    
    outputTexture[DTid.xy] = float4(distance, distance, distance, 1.0f);
    
}