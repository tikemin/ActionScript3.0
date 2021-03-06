﻿package{
	/*
	* FuzzyAHP算出プログラム 2011/12/06
	* V:vector
	* P:product
	* var result[加法性測度,可能性測度,必然性測度]
	*/
	public class FuzzyAHP {	
		private var result:Vector.<Vector.<Number>>;
		private var CI:Number;

		/*
		* コンストラクタ
		* var a:Vector.<Vector.<Number>>	一対比較の得点
		* var b:Vector.<Vector.<Number>>	評価値(行列)
		*/
		public function FuzzyAHP(a:Vector.<Vector.<Number>>, b:Vector.<Vector.<Number>>) {
			//初期化
			result =  Vector.<Vector.<Number>>([null]); result.pop();
			
			//λベクトルxの定義
			var x:Vector.<Number> = Vector.<Number>([ 1,0,0,0,0,1,0 ]);
			
			//重視度(正規化済)
			var impVal:Vector.<Number> = this.power(a,x);
			impVal = this.normVec1(impVal);

			/*
			* 各測度計算
			*/
			result.push(kahouMes(b ,impVal));//加法性測度
			result.push(kanouMes(b ,impVal));//可能性測度
			result.push(hitsuMes(b ,impVal));//必然性測度
		}
		
		/*
		* C.I.値の取得
		*/
		public function getCI():Number {
			return CI;
		}
		
		/*
		* 結果の取得
		*/
		public function getResult():Vector.<Vector.<Number>> {
			return result;
		}
		
		/*
		* 加法性測度
		*/
		function kahouMes(a:Vector.<Vector.<Number>> , vec:Vector.<Number>):Vector.<Number> {
			var kahouVec:Vector.<Number> = Vector.<Number>([null]); kahouVec.pop();
			for(var i:int = 0; i < a.length; i++) {
				var wh:Number = 0.0;
				for(var j:int = 0; j < vec.length; j++) {
					wh += a[i][j] * vec[j];
				}
				kahouVec.push(wh);
			}
			return kahouVec;
		}
		
		/*
		* 可能性測度
		*/
		function kanouMes(a:Vector.<Vector.<Number>> , vec:Vector.<Number>):Vector.<Number> {
			var kanouVec:Vector.<Number> = Vector.<Number>([null]); kanouVec.pop();
			for(var i:int = 0; i < a.length; i++) {
				var nVec:Vector.<Number> = this.normVec2(a[i]);
				var tmpVec:Vector.<Number> = Vector.<Number>([null]); tmpVec.pop();
				for(var j:int = 0; j < a[i].length; j++) {
					tmpVec.push(nVec[j] * vec[j]);
				}
				tmpVec.sort(1);
				kanouVec.push(tmpVec[0]);//最小値を格納
			}
			return kanouVec;
		}
		
		/*
		* 必然性測度
		*/
		function hitsuMes(a:Vector.<Vector.<Number>> , vec:Vector.<Number>):Vector.<Number> {
			var hitsuVec:Vector.<Number> = Vector.<Number>([null]); hitsuVec.pop();
			for(var i:int = 0; i < a.length; i++) {
				var wh:Number = 0.0;
				var nVec:Vector.<Number> = this.normVec2(a[i]);				
				for(var j:int = 0; j < a[i].length; j++) {
					wh += nVec[j] * vec[j];
				}
				hitsuVec.push(wh);
			}
			return hitsuVec;
		}
		
		/*
		* ベクトルの正規化(合計値が1)
		*/
		function normVec1(vec:Vector.<Number>):Vector.<Number> {
			var vecSUM:Number = 0.0;
			for each(var val:Number in vec) { vecSUM += val; }
			for(var i:int; i < vec.length; i++) {
				vec[i] = vec[i] / vecSUM;
			}
			
			return vec;
		}

		/*
		* ベクトルの正規化(合計値が1)
		*/
		function normVec2(vec:Vector.<Number>):Vector.<Number> {
			var vecCP:Vector.<Number> = vec;
			vecCP.sort(1);
			var maxVal:Number = vecCP[vecCP.length - 1];			
			for(var i:int; i < vec.length; i++) {
				vec[i] = vec[i] / maxVal;
			}
			
			return vec;
		}

		/*
		* 重視度算出(固有ベクトル算出)
		* a[N][N]:行列
		* b[N]:ベクトル
		*/
		function power(a:Vector.<Vector.<Number>> ,x:Vector.<Number>):Vector.<Number> {
			var eps:Number = Math.pow(10.0, -8.0);
			var lambda:Number = 0.0;
			var k:int = 0;
			var v:Vector.<Number> = x;

			do{
				if(k > 50) { break; }//終了条件(念のため)
				
				v = matrixVP(a ,x);
				lambda = innerP(v,x);
				var v2:Number = innerP(v,v);
				var v2s:Number = Math.sqrt(v2);
				for(var i:int = 0; i < v.length; i++) { x[i] = v[i] / v2s; }
				++k;
			}while(Math.abs(v2 - lambda * lambda) >= eps );

			CI = (lambda - v.length)/(v.length - 1.0);//C.I.計算
			return v;
		}
		
		/*
		* 内積計算
		*/
		function innerP(a:Vector.<Number>, b:Vector.<Number>):Number {
			var r:Number = 0.0;
			for(var i:int = 0; i < b.length; i++) r += a[i] * b[i];
			
			return r;
		}
		
		/*
		* 行列a[1...N][1...N]とベクトルb[1...N]の積
		* a[N][N]:行列
		* b[N]:ベクトル
		*/
		function matrixVP(a:Vector.<Vector.<Number>>, b:Vector.<Number>):Vector.<Number> {
			var wk:Number;
			var c:Vector.<Number> = new Vector.<Number>(b);
			for(var i:int = 0; i < a[0].length; i++){
				wk = 0.0;
				for(var j:int = 0; j < b.length; j++) {
					wk += a[i][j] * b[j];
				}
				c[i] = wk;
			}
			return c;
		}
	}
}