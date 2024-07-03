using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class TextScript : MonoBehaviour
{

	// Start is called before the first frame update
	void Start()
	{

	}

	// Update is called once per frame
	void Update()
	{
		TextMeshProUGUI text = gameObject.GetComponent<TextMeshProUGUI>();
		switch (PostEffectAttacher.select)
		{
			case PostEffectAttacher.SelectShader.Normal:
				text.text = "1 : Normal";
				break;
			case PostEffectAttacher.SelectShader.Gray:
				text.text = "2 : GrayScale";
				break;
			case PostEffectAttacher.SelectShader.Blur:
				text.text = "3 : GaussianBlur";
				break;
			case PostEffectAttacher.SelectShader.BloomG:
				text.text = "4 : Gaussian + Bloom";
				break;
			case PostEffectAttacher.SelectShader.BloomA:
				text.text = "5 : AngleBlur + Bloom";
				break;
		}
	}
}
