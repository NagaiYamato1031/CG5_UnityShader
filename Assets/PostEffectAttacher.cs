using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffectAttacher : MonoBehaviour
{
	// グレースケール
	public Shader grayScaleShader;
	private Material grayScaleMaterial;
	// ガウシアンブラー
	public Shader gaussianBlurShader;
	private Material gaussianBlurMaterial;
	// ブルーム
	public Shader bloomShader;
	private Material bloomMaterial;

	// ドット柄フィルターを ON にするか
	public bool dotFilter = false;

	// シェーダー選択
	public enum SelectShader
	{
		Normal = 0,
		Gray = 1,
		Blur = 2,
		BloomG = 3,
		BloomA = 4,
	}
	// 選択したもの
	public SelectShader select = SelectShader.Normal;

	// 直線的なぼかしの角度
	public Vector2 _BlurAngle = new Vector2(45, 135);
	public Vector2 _BlurAnglePad = new Vector2(20, 20);


	private enum ShaderFunc : int
	{
		HighLight = 0,
		AddTexture = 1,
		MulTexture = 2,
		GaussianBlur = 3,
		AngleBlur = 4,
		DotFilter = 5,
	}

	private void Start()
	{
		select = SelectShader.Gray;
	}

	private void Update()
	{
		if (Input.GetKeyDown(KeyCode.Alpha1))
		{
			select = SelectShader.Normal;
		}
		else if (Input.GetKeyDown(KeyCode.Alpha2))
		{
			select = SelectShader.Gray;
		}
		else if (Input.GetKeyDown(KeyCode.Alpha3))
		{
			select = SelectShader.Blur;
		}
		else if (Input.GetKeyDown(KeyCode.Alpha4))
		{
			select = SelectShader.BloomG;
		}
		else if (Input.GetKeyDown(KeyCode.Alpha5))
		{
			select = SelectShader.BloomA;
		}

		if (Input.GetKeyDown(KeyCode.Space))
		{
			dotFilter = !dotFilter;
		}
	}

	private void Awake()
	{
		grayScaleMaterial = new Material(grayScaleShader);
		gaussianBlurMaterial = new Material(gaussianBlurShader);
		bloomMaterial = new Material(bloomShader);
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		switch (select)
		{
			case SelectShader.Normal:
				Graphics.Blit(source, destination);
				break;
			case SelectShader.Gray:
				EffectGrayScale(source, destination);
				break;
			case SelectShader.Blur:
				EffectGaussianBlur(source, destination);
				break;
			case SelectShader.BloomG:
				EffectBloomGaussian(source, destination);
				break;
			case SelectShader.BloomA:
				EffectBloomAngle(source, destination);
				break;
		}
	}

	private void EffectGrayScale(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination, grayScaleMaterial);
	}

	private void EffectGaussianBlur(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination, gaussianBlurMaterial);
	}

	private void EffectBloomGaussian(RenderTexture source, RenderTexture destination)
	{
		RenderTexture highLumiTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
		RenderTexture blurTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

		// 高輝度画像抽出
		Graphics.Blit(source, highLumiTex, bloomMaterial, (int)ShaderFunc.HighLight);
		// ブラー処理
		Graphics.Blit(highLumiTex, blurTex, bloomMaterial, (int)ShaderFunc.GaussianBlur);
		bloomMaterial.SetTexture("_BlurTex", blurTex);
		// 合成
		Graphics.Blit(source, destination, bloomMaterial, (int)ShaderFunc.AddTexture);
		RenderTexture.ReleaseTemporary(highLumiTex);
		RenderTexture.ReleaseTemporary(blurTex);
	}

	private void EffectBloomAngle(RenderTexture source, RenderTexture destination)
	{
		RenderTexture highLumiTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
		RenderTexture blurTex0 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
		RenderTexture blurTex1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
		RenderTexture buffTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

		//// 交互に保存する
		//RenderTexture[] bufferTex = new RenderTexture[2];
		//// 線の数だけ
		//RenderTexture[] blurTex = new RenderTexture[3];
		//for (int i = 0; i < 2; i++)
		//{
		//	bufferTex[i] = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
		//}
		//for (int i = 0; i < 3; i++)
		//{
		//	blurTex[i] = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
		//}

		// ドット柄フィルターを使うか
		if (dotFilter)
		{
			// 高輝度画像抽出
			Graphics.Blit(source, buffTex, bloomMaterial, (int)ShaderFunc.HighLight);

			// ドット柄フィルター作成
			RenderTexture dotTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
			Graphics.Blit(source, dotTex, bloomMaterial, (int)ShaderFunc.DotFilter);
			// 乗算
			bloomMaterial.SetTexture("_BlurTex", buffTex);
			Graphics.Blit(dotTex, highLumiTex, bloomMaterial, (int)ShaderFunc.MulTexture);
			RenderTexture.ReleaseTemporary(dotTex);
		}
		else
		{
			// 高輝度画像抽出
			Graphics.Blit(source, highLumiTex, bloomMaterial, (int)ShaderFunc.HighLight);
		}

		//// 3 回
		//for (int i = 0; i < 3; i++)
		//{
		//	// ブラー処理
		//	bloomMaterial.SetFloat("_AngleDeg", _BlurAngle.x + _BlurAnglePad.x * (i - 1));
		//	Graphics.Blit(highLumiTex, blurTex[i], bloomMaterial, (int)ShaderFunc.AngleBlur);
		//}
		//// 0 と 1
		//bloomMaterial.SetTexture("_BlurTex", blurTex[0]);
		//Graphics.Blit(blurTex[1], bufferTex[0], bloomMaterial, (int)ShaderFunc.AddTexture);
		//// 2 と buffer[0]
		//bloomMaterial.SetTexture("_BlurTex", blurTex[2]);
		//Graphics.Blit(bufferTex[0], bufferTex[1], bloomMaterial, (int)ShaderFunc.AddTexture);

		//// 3 回
		//for (int i = 0; i < 3; i++)
		//{
		//	// ブラー処理
		//	bloomMaterial.SetFloat("_AngleDeg", _BlurAngle.y + _BlurAnglePad.y * (i - 1));
		//	Graphics.Blit(highLumiTex, blurTex[i], bloomMaterial, (int)ShaderFunc.AngleBlur);
		//}
		//// 0 と buffer[1]
		//bloomMaterial.SetTexture("_BlurTex", blurTex[0]);
		//Graphics.Blit(bufferTex[1], bufferTex[0], bloomMaterial, (int)ShaderFunc.AddTexture);
		//// 1 と buffer[0]
		//bloomMaterial.SetTexture("_BlurTex", blurTex[1]);
		//Graphics.Blit(bufferTex[0], bufferTex[1], bloomMaterial, (int)ShaderFunc.AddTexture);
		//// 2 と buffer[1]
		//bloomMaterial.SetTexture("_BlurTex", blurTex[2]);
		//Graphics.Blit(bufferTex[1], bufferTex[0], bloomMaterial, (int)ShaderFunc.AddTexture);

		//bloomMaterial.SetTexture("_BlurTex", bufferTex[0]);
		//Graphics.Blit(source, destination, bloomMaterial, (int)ShaderFunc.AddTexture);


		// ブラー処理
		bloomMaterial.SetFloat("_AngleDeg", _BlurAngle.x);
		Graphics.Blit(highLumiTex, blurTex0, bloomMaterial, (int)ShaderFunc.AngleBlur);
		// ブラー処理
		bloomMaterial.SetFloat("_AngleDeg", _BlurAngle.y);
		Graphics.Blit(highLumiTex, blurTex1, bloomMaterial, (int)ShaderFunc.AngleBlur);

		// 合成
		bloomMaterial.SetTexture("_BlurTex", blurTex0);
		Graphics.Blit(source, buffTex, bloomMaterial, (int)ShaderFunc.AddTexture);
		bloomMaterial.SetTexture("_BlurTex", blurTex1);
		Graphics.Blit(buffTex, destination, bloomMaterial, (int)ShaderFunc.AddTexture);

		//for (int i = 0; i < 2; i++)
		//{
		//	RenderTexture.ReleaseTemporary(bufferTex[i]);
		//}
		//for (int i = 0; i < 3; i++)
		//{
		//	RenderTexture.ReleaseTemporary(blurTex[i]);
		//}
		RenderTexture.ReleaseTemporary(blurTex0);
		RenderTexture.ReleaseTemporary(blurTex1);
		RenderTexture.ReleaseTemporary(highLumiTex);
		RenderTexture.ReleaseTemporary(buffTex);
	}
}
