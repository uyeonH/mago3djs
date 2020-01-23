attribute vec3 position;
attribute vec3 normal;
attribute vec4 color4;
attribute vec2 texCoord;

uniform mat4 projectionMatrix;  
uniform mat4 modelViewMatrix;
uniform mat4 modelViewMatrixInv;
uniform mat4 modelViewMatrixRelToEye; 
uniform mat4 ModelViewProjectionMatrixRelToEye;
uniform mat4 ModelViewProjectionMatrix;
uniform mat4 normalMatrix4;
uniform mat4 sunMatrix[2]; 
uniform mat4 buildingRotMatrix;  
uniform vec3 buildingPosHIGH;
uniform vec3 buildingPosLOW;
uniform vec3 sunPosHIGH[2];
uniform vec3 sunPosLOW[2];
uniform vec3 sunDirWC;
uniform vec3 encodedCameraPositionMCHigh;
uniform vec3 encodedCameraPositionMCLow;
uniform vec3 aditionalPosition;
uniform vec4 oneColor4;
uniform bool bUse1Color;
uniform bool hasTexture;
uniform bool bIsMakingDepth;
uniform float near;
uniform float far;
uniform bool bApplyShadow;
uniform int sunIdx;

varying vec3 vNormal;
varying vec2 vTexCoord;   
varying vec3 uAmbientColor;
varying vec3 vLightWeighting;
varying vec4 vcolor4;
varying vec3 v3Pos;
varying float depthValue;

varying vec4 vPosRelToLight; 
varying vec3 vLightDir; 
varying vec3 vNormalWC;
varying float currSunIdx;

void main()
{	
    vec3 objPosHigh = buildingPosHIGH;
    vec3 objPosLow = buildingPosLOW.xyz + position.xyz;
    vec3 highDifference = objPosHigh.xyz - encodedCameraPositionMCHigh.xyz;
    vec3 lowDifference = objPosLow.xyz - encodedCameraPositionMCLow.xyz;
    vec4 pos4 = vec4(highDifference.xyz + lowDifference.xyz, 1.0);
	
	currSunIdx = -1.0; // initially no apply shadow.
	if(bApplyShadow && !bIsMakingDepth)
	{
		vLightDir = sunDirWC;
		vec3 rotatedNormal = vec3(0.0, 0.0, 1.0); // provisional.***
		vNormalWC = rotatedNormal;
					
		// the sun lights count are 2.
		vec3 currSunPosLOW;
		vec3 currSunPosHIGH;
		mat4 currSunMatrix;
		if(sunIdx == 0)
		{
			currSunPosLOW = sunPosLOW[0];
			currSunPosHIGH = sunPosHIGH[0];
			currSunMatrix = sunMatrix[0];
			currSunIdx = 0.5;
		}
		else if(sunIdx == 1)
		{
			currSunPosLOW = sunPosLOW[1];
			currSunPosHIGH = sunPosHIGH[1];
			currSunMatrix = sunMatrix[1];
			currSunIdx = 1.5;
		}
		
		// Calculate the vertex relative to light.***
		vec3 highDifferenceSun = objPosHigh.xyz - currSunPosHIGH.xyz;
		vec3 lowDifferenceSun = objPosLow.xyz - currSunPosLOW.xyz;
		vec4 pos4Sun = vec4(highDifferenceSun.xyz + lowDifferenceSun.xyz, 1.0);
		vec4 posRelToLightAux = currSunMatrix * pos4Sun;
		
		// now, check if "posRelToLightAux" is inside of the lightVolume (inside of the depthTexture of the light).
		vec3 posRelToLightNDC = posRelToLightAux.xyz / posRelToLightAux.w;
		vPosRelToLight = posRelToLightAux;
	}

	if(bIsMakingDepth)
	{
		depthValue = (modelViewMatrixRelToEye * pos4).z/far;
	}
	else
	{
		vTexCoord = texCoord;
	}
    gl_Position = ModelViewProjectionMatrixRelToEye * pos4;
	v3Pos = gl_Position.xyz;
}