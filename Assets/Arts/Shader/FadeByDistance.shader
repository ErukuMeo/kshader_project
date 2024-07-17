Shader "Sprites/FadeByDistance"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FadeDistanceNear("Near Fadeout dist", float) = 0
        _FadeDistanceFar("Far Fadeout dist", float) = 10
        _FadeDistanceRange("Fadeout Range", Float) = 1
    }
    SubShader
    {
        Tags {
            "Queue" = "Transparent"
            "RenderType"="Transparent"
        }
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

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
                float fade: TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FadeDistanceNear;
            float _FadeDistanceFar;
            float _FadeDistanceRange;// 小于或大于此距离，完全隐藏

            v2f vert (appdata v)
            {
                v2f o;
                // 转为裁剪空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // 相机坐标系的物体坐标
                float3 pos_in_view = mul(UNITY_MATRIX_MV, v.vertex).xyz;
                // 计算与相机的距离
                // float dis = length(pos_in_view);
                // 计算与相机平面的距离
                float dis = abs(pos_in_view.z);
                // 计算fade
                if (dis < _FadeDistanceNear)
                {
                    // 小于最近距离，开始渐变
                    o.fade = 1 - saturate((_FadeDistanceNear-dis) / _FadeDistanceRange);
                } else
                {
                    o.fade = 1 - saturate((dis - _FadeDistanceFar) / _FadeDistanceRange);
                }
                // 备份：原始fade逻辑
                // o.fade = 1 - saturate((dis - _FadeDistanceNear) / (_FadeDistanceFar - _FadeDistanceNear));
                return o;
                // v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                // return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 对UV进行采样
                float4 texCol = tex2D(_MainTex, i.uv);
                float4 outp = texCol;
                return float4(outp.rgb, i.fade);
                // // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // return col;
            }
            ENDCG
        }
    }
}
