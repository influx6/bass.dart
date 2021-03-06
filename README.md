#Bass

##Description
	Inspired by AbsurdJS(http://absurdjs.com/) towards building a css-preprocessor using the native core language itself and with dartlang sophisticated constructs and limitless possiblilites arises when we rather than create limited pre-processor we use the built-in functionality of dartlang and a few constructs that simplify life,that is what Bass provides,allowing you to leverag dartlang's in such a way,Bass goes beyond just css as it provides a basic rule based system that depending on implementation can drastically change,such as making it into an html pre-processor although for now such is not planned.

##Examples:
	'''

		Bass.debug.enable; // enables printing of debug information( generally internal bass style process)

		/*
			Bass.NS(String)
			creates an instance of BassNS with a name-spaced value (which just acts as an identifier)

		*/
		var box = Bass.NS('dashboard-ui');

		/*
		 Bass.css();
		 returns an instance of a BassFormatter that basically takes the generated map when Bass.compile is called and then converts it into proper css notation
		*/
		var css = box.css();

		/*
			BassNS.mixFn(String,Function)
			adds a function for use late as a mixin mixin 

		*/
		box.mixFn('relWidth',(n,b){ return n + b / 100; });

		/*
		 	BassNS.composeFn(String,List<String>,Numer of arugments for the last function in the list)
		 	allows the composition of multiple functions already existing under another namespace
		*/
		box.composeFn('%width',['%','relWidth'],2);
              
                /*
                   Note:
                   mixins are evaluated immediately,due to the nature that they could cause an unfortunately
                   looping for example
                   if we had  2 mixins: 
                    
                      box.mix('bugger',{
                              '@mix':'foul'
                      });

                      box.mix('foul',{
                              '@mix':'bugger'
                      });

                  if these are lazy evaluated,we would endup in an endless loop of evaluating mixins,even if
                  either bugger or foul are called within deeper mixins it will result in these error which
                  would cause a stackoverflow ,to mitigate these mixins are immediately evaluated in the order
                  they are added to ensure to negate such possiblities and also improve scanning,as if a mixin
                  legitimately includes another mixins as far as the mixin existed before this current mixin
                  the mixin will be evaluated correctly.

                  So ensure to add mixins sequentially in the order of use if you plan on mixin other mixins 
                  into other mixins
                */

		/*
			BassNS.mix(String,Map)
			allows the addition of reusable mixins
		*/
		box.mix('flatwidth',{
			'width':'100%'
		});

		box.mix('flatfont',{
			'font-size':'100%'
		});

		/*
			BassNS.mixVar(String,dynamic)
			allows the addition of reusable variables (which provides an advantage as a mixin)
		*/
		box.mixVar('line-height','300px');

		/*
			BassNS.bind,BassNS.unbind,BassNS.bindOnce,BassNS.unbindOnce
			allows multiple listenings for when a new css map is generated while the compile Function is called.
			This returns a processed map
		*/
		box.bind(Funcs.tag('scanMap:'));
		
		/*
			BaseFormatter.bind just like above binds into the formatter calback system,this returns a string of css
		*/
		css.bind(Funcs.tag('scanMap:'));

		/*
			BassNS.sel
			the core of style definition,allowing the definition of a style for a psecific selector,
			the & symbol like in less will be replaced with the value of the selector

			Rules:
			@mix will mix in the value styles given to it
			@mixvar allows for mixin in variables values passed in to mixVar,very useful for multiple assignment or just use standard dart varaiables

			Also these rules are actually added by default and the rules can be extended to include more functionality and varieties,enjoy
		*/
		box.sel('body',{
			'@mix': 'flatwidth,flatfont',
			'line-height': box.vars('line-height'),
			'height': box.fn('%width',[10,10]),
			'h1':{
				'@mix': 'flatwidth',
				'@mixvar': 'line-height:#line-height,chicken:#line-height',
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

		/*
			BassNS.compile
			initiates the pre-processing and returns a new object with all values sorted out and properly
			placed in,to make a pretty print format use the Func.prettyPrint in the Hub library or any other formatter that suites, the idea is the processed map can now be turned into any format from json to yaml as the user sees fit
		*/
		box.compile();
		
		/*
			BassNS.updateSel
			allows the updating of an already defined selector and it styles
		*/
		box.updateSel('body',{
			'& *':{
				'width':'100px',
				'dd':'40px'
			},
			'& div[type="checkbox"]':{
				'color': 'red'
			}
		});

		box.compile();
	'''
	
##ThanksGiving
To God alone be all glory,praise and thanks for both this and many more,amen!
