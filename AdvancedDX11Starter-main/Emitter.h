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

struct Particle
{
	float emitTime;
	XMFLOAT3 startPos;
};

class Emitter
{
public:
	Emitter(float pLifetime, int emitRate, wstring texturePath,
		Microsoft::WRL::ComPtr<ID3D11Device> device,
		Microsoft::WRL::ComPtr<ID3D11DeviceContext> context);
	~Emitter();

	/// <summary>
	/// Tracks lifetimes and emits particles 
	/// </summary>
	void Update(float delta);
	/// <summary>
	/// Sends CPU date to GPU 
	/// </summary>
	void Draw();


private:
	// Particle Info 
	Particle* particles;
	int liveStart;
	int liveEnd;
	int liveCount;

	float currentTime; 
	int ringBufferSize;

	// Emission Properties 
	float pLifetime;
	int emitRate; // Particles per second 
	float timeBetweenParticles; // Time between each particle emmision 
	float timeSinceLastEmit;

	// Rendering Resources 
	Microsoft::WRL::ComPtr<ID3D11Buffer> particleBuffer;
	Microsoft::WRL::ComPtr<ID3D11ShaderResourceView> particleTexture;
	Microsoft::WRL::ComPtr<ID3D11Buffer> indexBuffer;

	std::shared_ptr<SimpleVertexShader> vs;
	std::shared_ptr<SimplePixelShader> ps;

	// Helpers
	void SendToGPU(int start, int end);
};