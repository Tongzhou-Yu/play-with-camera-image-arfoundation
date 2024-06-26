Shader "Unlit/TextureBothSide"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // flip the texture along the Y axis
                float2 flippedUV = float2(i.uv.x, 1 - i.uv.y);

                // calculate the rotation matrix for 180 degrees rotation
                float2x2 rotationMatrix = float2x2(
                cos(radians(180)), sin(radians(180)),
                -sin(radians(180)), cos(radians(180))
                );
    // rotate the texture coordinates
    float2 centeredUV = flippedUV - float2(0.5, 0.5);
    float2 rotatedUV = mul(rotationMatrix, centeredUV) + float2(0.5, 0.5);

    // sample the texture
    fixed4 col = tex2D(_MainTex, rotatedUV);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
