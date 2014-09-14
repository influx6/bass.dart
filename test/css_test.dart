library bass.spec;

import 'package:hub/hub.dart';
import 'package:bass/bass.dart';

void main(){

	/*Bass.debug.enable;*/

	var box = CSS.create();

	box.ns.mixFn('relWidth',(n,b){ return n + b / 100; });
	box.ns.composeFn('%width',['%','relWidth'],2);

	box.ns.mix('flatwidth',{
		'width':'100%'
	});

	box.ns.mix('fluidHeight',{
		'height-fluid':'100%'
	});

	box.ns.mix('flatfont',{
		'font-size':'100%'
	});

	box.ns.mixVar('line-height','300px');


	box.ns.sel('body',{
		'@mix': 'flatwidth,flatfont',
		'line-height': box.ns.vars('line-height'),
		'height': box.ns.fn('%width',[10,10]),
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

	box.f.bind(Funcs.tag('scanMap:'));
	box.ns.compile();
        
	
	box.ns.updateSel('body',{
                '@mix':'fluidHeight',
                '@include':{
                  'background':'white',
                  'rotate':'90deg'
                },

		'& *':{
			'width':'100px',
			'dd':'40px'
		},
		'& div[type="checkbox"]':{
			'color': 'red'
		},
              'h1':{
                '@mix':'flatfont'
              }
	});

        print('\n');
	box.ns.compile();

        box.destroy();
}
