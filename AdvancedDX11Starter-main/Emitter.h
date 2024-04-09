#pragma once

#include <DirectXMath.h>
#include <wrl/client.h>
#include <d3d11.h>
#include <vector>
#include <memory>
#include "SimpleShader.h"
#include <string>

using namespace DirectX;
using namespace std;

class Particle
{
	float emitTime;
	XMFLOAT3 startPos;
};

class Emitter
{
public:
	Emitter();

	void Update();
	void Draw(float pLifetime, int emitRate, string texturePath);


private:
	// Particle Info 
	std::vector<Particle> particles;
	int liveStart;
	int liveEnd;
	int liveCount;

	// Emission Properties 
	float pLifetime;
	int emitRate; // Particles per second 
	float timerBetweenParticles; // Time between each particle emmision 
	float timeSinceLastEmit;

	// Rendering Resources 
	Microsoft::WRL::ComPtr<ID3D11Buffer> particleBuffer;
	Microsoft::WRL::ComPtr<ID3D11Resource> particelTexture;
	Microsoft::WRL::ComPtr<ID3D11Buffer> indexBuffer;

	std::shared_ptr<SimpleVertexShader> vs;
	std::shared_ptr<SimplePixelShader> ps;
};