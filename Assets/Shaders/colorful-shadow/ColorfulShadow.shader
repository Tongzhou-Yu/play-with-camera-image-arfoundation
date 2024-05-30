Shader "Unlit/ColorfulShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Mask", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _MaskTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                            // Correcting ratio from 2688x1242 to 1920x1440
            float ratio = 1.62;


    // Create a rotation matrix for 90 degrees
    float2x2 rotation = float2x2(
        cos(90.0 * 3.14159 / 180.0), -sin(90.0 * 3.14159 / 180.0),
        sin(90.0 * 3.14159 / 180.0), cos(90.0 * 3.14159 / 180.0)
    );

    // Apply rotation to the UV coordinates
    float2 rotatedUV = mul(i.uv - 0.5, rotation) + 0.5;

    // Flip the UV coordinates along the x-axis
    rotatedUV.x = 1.0 - rotatedUV.x;

    // Wrap the UV coordinates back into the [0,1] range
    rotatedUV = frac(rotatedUV);

    rotatedUV.y /= ratio;
    rotatedUV.y += 1.0 - (ratio * 0.5);

    fixed4 mask = tex2D(_MaskTex, rotatedUV);
                col.a *= mask.r; // Use the red channel of the mask texture to control the alpha
                return col;
            }
            ENDCG
        }
    }
}