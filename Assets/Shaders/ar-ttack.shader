Shader "Custom/ar-ttack"
{
    Properties
    {
        
        _MainTex("RenderTexture", 2D) = "white" {}
        _SnowTex("SnowTexture", 2D) = "white" {}
        _SnowColor("SnowColor", Color) = (0,0,0,0)
        _Noise("SnowNoise", 2D) = "black" {}
        _SnowCount("SnowCount", float) = 1
        //_SelfShadow("SelfShadow",Range(0, 1)) = 0.5
        _SnowControl("SnowControl (x:Noise R y:Noise G z:Sonw)",vector) = (1,1,1,0.5)
        _Direction("Direction (1:Peak -1:Hole)",int) = 1
            //X:Noise贴图红色通道的Tiling, Y:Noise贴图蓝色通道的Tiling, Z:雪贴图的Tiling, W:noise混合的边缘过度
            
            // _ScopeTexと_Thresholdを追加
    _ScopeTex("Scope", 2D) = "white" {}
    _Threshold("Threshold", Range(0,10)) = 10
            // --------- : Displacement
    _DispTex("Displacement Texture", 2D) = "gray" {}
    _Displacement("Displacement", Range(0, 10.0)) = 0.1
    _ChannelFactor("ChannelFactor (r,g,b)", Vector) = (1,0,0)
        // ---------
    }
        SubShader
        {
            Pass
            {
                CGPROGRAM
                #pragma target 3.0
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                fixed _SelfShadow;
                half _SnowCount;
                sampler2D _Noise;
                sampler2D _SnowTex;
                fixed4 _SnowColor;
                half4 _SnowControl;

                struct appdata_t
                {
                    float4 vertex : POSITION;
                    float4 color : COLOR;
                    float2 texcoord0 : TEXCOORD0;
                    float2 texcoord1 : TEXCOORD1;

                    // --------- : Displacement
                    float3 normal : NORMAL;                   //normal direction
                    float4 tangent : TANGENT;                 //tangent direction
                    // ---------
                };

                struct v2f
                {
                    float4 pos : POSITION;
                    float4 uvColor : TEXCOORD0;
                    fixed4 snowControl : COLOR;
                    float2 screenpos : TEXCOORD1;
                };

                sampler2D _MainTex;
                sampler2D _ScopeTex;
                float _Threshold;
                // --------- : Displacement
                sampler2D _DispTex;
                float4 _DispTex_ST;
                float _Displacement;
                float3 _ChannelFactor;
                // ---------
                int _Direction;

                v2f vert(appdata_t IN)
                {
                    v2f OUT;
                    // --------- : 追加
                    float4 deform = tex2Dlod(_ScopeTex, float4(IN.texcoord0.xy, 0, 0));
                    float ratio = _Threshold * deform;
                    float4 _vertex = IN.vertex;
                    // --------- : Displacement
                    float3 dcolor = tex2Dlod(_DispTex, float4(IN.texcoord0 * _DispTex_ST.xy, 0, 0));
                    float d = (dcolor.r * _ChannelFactor.r + dcolor.g * _ChannelFactor.g + dcolor.b * _ChannelFactor.b);
                    // --------- 
                    // --------- : Displacement
                    _vertex.xyz += IN.normal * d * _Displacement;      //Displacement
                    // --------- 
                    UNITY_SETUP_INSTANCE_ID(v);
                    OUT.pos = UnityObjectToClipPos(_vertex);//⭐
                    //xy分量用来采样模型的Color贴图
                    OUT.uvColor.xy = IN.texcoord0;
                    //zw分量用来采样snow、noise、阴影等贴图
                    OUT.uvColor.zw = IN.texcoord1;
                    //用模型世界空间的法线跟（0, 1, 0）也就是Y轴向做一个夹角的计算，来实现只有横着的面有雪的覆盖
                    OUT.snowControl = saturate(dot(fixed3(0, 0, _Direction), normalize(_vertex.xyz)));
                    //OUT.snowControl = IN.color;
                    //fixed3.y 控制正反

                    float4 objectToClipPos = UnityObjectToClipPos(IN.vertex);
                    float4 spreenPos = ComputeScreenPos(objectToClipPos);
                    float2 uv = spreenPos.xy / spreenPos.w;

                    OUT.screenpos = uv;
                    return OUT;
                }

                fixed4 frag(v2f IN) : SV_Target
                {
                    fixed n1 = tex2D(_Noise, IN.uvColor.zw * _SnowControl.x).r;
                    fixed n2 = tex2D(_Noise, IN.uvColor.zw * _SnowControl.y).g;
                    fixed noise = saturate((n1 * n2 * IN.snowControl * _SnowCount - _SnowControl.w) / (1 - _SnowControl.w));
                    float2 xy = IN.screenpos.xy;
                    half4 c = tex2D(_MainTex, xy); 
                    fixed4 col = c* (1 - noise) + tex2D(_SnowTex, _SnowControl.z) * noise * _SnowColor;

                    //col *= c.a * _SelfShadow + (1 - _SelfShadow);

                    return col;
                }
                ENDCG
            }
        }
}