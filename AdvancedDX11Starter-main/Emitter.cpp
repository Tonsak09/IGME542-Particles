#pragma once
#include "Emitter.h"
#include "Camera.h"

#include "WICTextureLoader.h"

#include "Helpers.h"

Emitter::Emitter(float pLifetime, int emitRate, int maxParticles, std::shared_ptr<Material> pMat, 
	Microsoft::WRL::ComPtr<ID3D11Device> device,
	Microsoft::WRL::ComPtr<ID3D11DeviceContext> context) :
	pLifetime(pLifetime), emitRate(emitRate), ringBufferSize(maxParticles), material(pMat), device(device), context(context)
{
	currentTime = 0.0f;
	timeSinceLastEmit = 0.0f;

	particles = new Particle[maxParticles];

	timeBetweenParticles = 1.0f / emitRate;
	liveStart = 0;
	liveEnd = 0;
	liveCount = 0;

	transform = std::make_shared<Transform>();

	InitBuffers();
}
Emitter::~Emitter()
{
	delete[] particles;
}

void Emitter::InitBuffers()
{
	// Don't store a vertex buffer since we will be 
	// making our 
	UINT stride = 0;
	UINT offset = 0;
	ID3D11Buffer* nullBuffer = 0;
	context->IASetVertexBuffers(0, 1, &nullBuffer, &stride, &offset);
	context->IASetIndexBuffer(indexBuffer.Get(), DXGI_FORMAT_R32_UINT, 0);

	// Send data to vertex shader 
	/*std::shared_ptr<SimpleVertexShader> vs = material->GetVertexShader();
	vs->SetShaderResourceView("Particles", particleDataSRV);*/

	// Populate the buffer with data 
	D3D11_BUFFER_DESC allParticleBufferDesc = {};
	allParticleBufferDesc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
	allParticleBufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
	allParticleBufferDesc.Usage = D3D11_USAGE_DYNAMIC;
	allParticleBufferDesc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_STRUCTURED;
	allParticleBufferDesc.StructureByteStride = sizeof(Particle);
	allParticleBufferDesc.ByteWidth = sizeof(Particle) * ringBufferSize;
	device->CreateBuffer(&allParticleBufferDesc, 0, particleBuffer.GetAddressOf());

	// Connect our shader resource view to the buffer of particles 
	D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = {};
	srvDesc.ViewDimension = D3D11_SRV_DIMENSION_BUFFER;
	srvDesc.Format = DXGI_FORMAT_UNKNOWN;
	srvDesc.Buffer.FirstElement = 0;
	srvDesc.Buffer.NumElements = ringBufferSize;
	device->CreateShaderResourceView(particleBuffer.Get(), &srvDesc, particleDataSRV.GetAddressOf());


	// Letus make our index buffer!!! YAhhooo! 
	int numIndices = ringBufferSize * 6;
	unsigned int* indices = new unsigned int[numIndices];
	int indexCount = 0;
	for (int i = 0; i < ringBufferSize * 4; i += 4)
	{
		indices[indexCount++] = i;
		indices[indexCount++] = i + 1;
		indices[indexCount++] = i + 2;
		indices[indexCount++] = i;
		indices[indexCount++] = i + 2;
		indices[indexCount++] = i + 3;
	}
	D3D11_SUBRESOURCE_DATA indexData = {};
	indexData.pSysMem = indices;
	delete[] indices;

	// Set indicies to index buffer 
	D3D11_BUFFER_DESC ibDesc = {};
	ibDesc.BindFlags = D3D11_BIND_INDEX_BUFFER;
	ibDesc.CPUAccessFlags = 0;
	ibDesc.Usage = D3D11_USAGE_DEFAULT;
	ibDesc.ByteWidth = sizeof(unsigned int) * ringBufferSize * 6;
	device->CreateBuffer(&ibDesc, &indexData, indexBuffer.GetAddressOf());
}

/// <summary>
/// Tracks lifetimes and emits particles 
/// </summary>
void Emitter::Update(float delta)
{
	currentTime += delta;
	timeSinceLastEmit += delta;

	// Iterate through each particle and check lifetime
	// Does need to emit 

	// Note: We want to get rid of all particles
	//		 that should be dead this update instead
	//		 of letting them grow and only killing one 
	//		 at a time each update 

	int currIndex = liveStart;
	for (int i = 0; i < liveCount; i++)
	{
		if (currentTime - particles[currIndex].emitTime < pLifetime)
		{
			liveStart = currIndex;

			// New beginning found 
			break;
		}

		// Particle has gone passed lifetime 
		currIndex++; 
		liveCount--;
		if (currIndex >= ringBufferSize)
		{
			currIndex = 0;
		}

		liveStart = currIndex;
	}

	//printf("timeSinceLastEmit: %f \n", timeSinceLastEmit);
	
	if (timeSinceLastEmit > timeBetweenParticles)
	{
		// In case multiple need to be spawned 
		int count = timeSinceLastEmit / timeBetweenParticles;

		// Dis to max from next end 
		int nextEndToBufferMax = ringBufferSize - (liveEnd + count);

		if (nextEndToBufferMax < 0)
		{
			// Split into two chunks 
			
			int currToMaxDis = ringBufferSize - liveEnd;
			for (int i = 0; i < currToMaxDis; i++)
			{
				particles[liveEnd + i + 1].emitTime = currentTime;
				// Set start pos 
			}

			// Looped
			// Note: currEndToBufferMax represents overflow 
			// Todo: Does not account for multiple overflow 
			int overFlow = abs(nextEndToBufferMax);
			for (int i = 0; i < overFlow; i++)
			{
				particles[i].emitTime = currentTime;
			}

			liveEnd = overFlow;

		}	
		else
		{
			// Does not loop buffer 
			for (int i = 0; i < count; i++)
			{
				particles[liveEnd + i + 1].emitTime = currentTime;
				// Set start pos 
			}

			liveEnd = liveEnd + count;
		}
		timeSinceLastEmit = 0.0f;
		liveCount += count;
	}

	printf("Start: %i End: %i \n", liveStart, liveEnd);
}

/// <summary>
/// Sends CPU date to GPU 
/// </summary>
void Emitter::Draw(std::shared_ptr<Camera> camera)
{

	//// Does this need to be split into two? 
	//if (liveEnd < liveStart)
	//{
	//	// Send into two batches
	//	SendToGPU(liveStart, ringBufferSize - 1);
	//	SendToGPU(0, liveEnd);
	//}
	//else
	//{
	//	// Send in one batch 
	//	SendToGPU(liveStart, liveEnd);
	//}

	D3D11_MAPPED_SUBRESOURCE mapped = {};
	context->Map(particleBuffer.Get(), 0, D3D11_MAP_WRITE_DISCARD, 0, &mapped);

	// How are living particles arranged in the buffer?
	if (liveStart < liveEnd)
	{
		// Only copy from FirstAlive -> FirstDead
		memcpy(
			mapped.pData, // Destination = start of particle buffer
			particles + liveStart, // Source = particle array, offset to first living particle
			sizeof(Particle) * liveCount); // Amount = number of particles (measured in BYTES!)
	}
	else
	{
		// Copy from 0 -> FirstDead 
		memcpy(
			mapped.pData, // Destination = start of particle buffer
			particles, // Source = start of particle array
			sizeof(Particle) * liveEnd); // Amount = particles up to first dead (measured in BYTES!)

		// ALSO copy from FirstAlive -> End
		memcpy(
			(void*)((Particle*)mapped.pData + liveEnd), // Destination = particle buffer, AFTER the data we copied in previous memcpy()
			particles + liveStart,  // Source = particle array, offset to first living particle
			sizeof(Particle) * (ringBufferSize - liveStart)); // Amount = number of living particles at end of array (measured in BYTES!)
	}

	// Unmap now that we're done copying
	context->Unmap(particleBuffer.Get(), 0);

	UINT stride = 0;
	UINT offset = 0;
	ID3D11Buffer* nullBuffer = 0;
	context->IASetVertexBuffers(0, 1, &nullBuffer, &stride, &offset);
	context->IASetIndexBuffer(indexBuffer.Get(), DXGI_FORMAT_R32_UINT, 0);

	// Set particle-specific data and let the
	// material take care of the rest
	material->PrepareMaterial(transform.get(), camera);

	std::shared_ptr<SimpleVertexShader> vs = material->GetVertexShader();
	vs->SetMatrix4x4("view", camera->GetView());
	vs->SetMatrix4x4("projection", camera->GetProjection());
	vs->CopyAllBufferData();

	// Send to structured buffer 
	vs->SetShaderResourceView("Particles", particleDataSRV);
	
	context->DrawIndexed(liveCount * 6, 0, 0);

}

/// <summary>
/// Sends particle specific information to the GPU
/// </summary>
/// <param name="start"></param>
/// <param name="end"></param>
void Emitter::SendToGPU(int start, int end)
{
	D3D11_MAPPED_SUBRESOURCE mapped = {};
	context->Map(particleBuffer.Get(), 0, D3D11_MAP_WRITE_DISCARD, 0, &mapped);

	memcpy(
		mapped.pData,
		particles + start, // Go to beginning 
		sizeof(Particle) * (end - start)); // How much after 

	// No longer sending data over 
	context->Unmap(particleBuffer.Get(), 0);



	
}