library bass.spec;

import 'package:hub/hub.dart';
import 'package:bass/bass.dart';

void main(){

	/*Bass.debug.enable;*/

	var box = Bass.NS('dashboard-ui');
	var css = box.css();

	box.mixFn('relWidth',(n,b){ return n + b / 100; });
	box.composeFn('%width',['%','relWidth'],2);

	box.mix('flatwidth',{
		'width':'100%'
	});

	box.mix('fluidHeight',{
		'height-fluid':'100%'
	});

	box.mix('flatfont',{
		'font-size':'100%'
	});

	box.mixVar('line-height','300px');


	box.sel('body',{
		'@mix': 'flatwidth,flatfont',
		'line-height': box.vars('line-height'),
		'height': box.fn('%width',[10,10]),
		'h1':{
			'@mix': 'flatwidth',
			'@mixvar': 'line-height:#line-height|chicken:#line-height',
		},
		":hover":{
			'width':'200px'
		},
		'> div':{
			'width':'200px'
		},
		'&:active, &:selected':{
			'color': 'white'
		},
		'& sprocks':{

		},
		'& *': {
			'dd':20
		},
		//this will be excluded as undesired,unless bass.strictkeys.switchoff() is called
		'&':{
			'sol': 'bool'
		}
	});

	box.compile();
	css.bind(Funcs.tag('scanMap:'));
	
	box.updateSel('body',{
                '@mix':'fluidHeight',
                '@include':{
                  'background':'white',
                  'rotate':'90deg'
                },

		'& *':{
			'width':'100px',
			/*'dd':'40px'*/
		},
		'& div[type="checkbox"]':{
			'color': 'red'
		},
	});

	box.compile();
}
