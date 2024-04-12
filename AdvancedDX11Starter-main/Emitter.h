#pragma once

#include <DirectXMath.h>
#include <wrl/client.h>
#include <d3d11.h>
#include <vector>
#include <memory>
#include "SimpleShader.h"
#include <string>
#include "Material.h"

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
	Emitter(float pLifetime, int emitRate, int maxParticles, std::shared_ptr<Material> pMat,
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
	void Draw(std::shared_ptr<Camera> camera);


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

	// Additional attributes 
	float noiseScale;
	XMFLOAT3 startScale;
	XMFLOAT3 targetScale;
	int scaleCurve;
	XMFLOAT4 startColor;
	XMFLOAT4 targetColor;
	int colorCurve;
	float gravityScale;
	float rotSpeed;


	// Rendering Resources 
	Microsoft::WRL::ComPtr<ID3D11Buffer> particleBuffer;
	Microsoft::WRL::ComPtr<ID3D11ShaderResourceView> particleDataSRV;
	Microsoft::WRL::ComPtr<ID3D11Buffer> indexBuffer;

	Transform transform;
	std::shared_ptr<Material> material;

	std::shared_ptr<SimpleVertexShader> vs;
	std::shared_ptr<SimplePixelShader> ps;

	Microsoft::WRL::ComPtr<ID3D11Device> device;
	Microsoft::WRL::ComPtr<ID3D11DeviceContext> context;

	// Helpers
	void SendToGPU(int start, int end, D3D11_MAPPED_SUBRESOURCE& mapped);
	void InitBuffers();
};