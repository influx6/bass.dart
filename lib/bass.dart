library bass;

import 'package:hub/hub.dart';

/*
	Rules are simple, you define a markup type that follows the basic standard in a css declaration
	ie:
		"@rule":"rule_value_to_process"
	eg:	
		.flatwidth{
			width: 100%;
		}

		.flatheight{
			height: 100%;
		}

		body{
			"@mixin":".flatwidth"
			"@mixin":".flatheight"
		}

*/
class Rule{
	String method;
	Function ruleProcessor;

	static create(s,r) => new Rule(s,r);
	Rule(this.method,this.ruleProcessor);

	Map process(dynamic n,BassNS b) => this.ruleProcessor(n,b);
	void destroy(){
		this.method = this.ruleProcessor = null;
	}
}

class RuleSet{
	MapDecorator rules;

	static create() => new RuleSet();

	RuleSet(){
		this.rules = MapDecorator.create();
	}

	bool hasRule(String n) => this.rules.has(n);

	void rule(String n,Function m){
		this.rules.update(n,Rule.create(n,m));
	}

	dynamic get(String n) => this.rules.get(n);

	void remove(String n){
		if(!this.rules.has(n)) return null;
		this.rules(n).destroy();
	}

	void destroy(){
		this.rules.onAll((k,v) => v.destroy());
		this.rules.clear();
	}
}

class Style{
	String selector;
	MapDecorator rules;
	Map maps;

	static create(s,m) => new Style(s,m);
	Style(this.selector,this.maps){
		this.rules = new MapDecorator.use(this.maps);
	}
	void destroy(){
		this.selector = null;
		this.rules.clear();
		this.maps.clear();
	}
}

class StyleSet{
	MapDecorator styles;

	static create() => new StyleSet();

	StyleSet(){
		this.styles = MapDecorator.create();
	}

	void style(String n,Map m){
		this.styles.update(n,Style.create(n,m));
	}


	bool hasStyle(String n) => this.styles.has(n);

	dynamic get(String n) => this.styles.get(n);
	dynamic getMaps(String n) => this.hasStyle(n) ? this.styles.get(n).maps : null;

	void remove(String n){
		if(!this.styles.has(n)) return null;
		this.styles(n).clear();
	}

	void destroy(){
		this.styles.onAll((k,v) => v.destroy());
		this.styles.clear();
	}
}

class SelectorRule{
	MapDecorator rules;

	static create() => new SelectorRule();
	SelectorRule(){
		this.rules = MapDecorator.create();
	}

	void addRule(String ns,RegExp r,Function m){
		if(this.rules.has(ns)) return null;
		this.rules.add(ns,{'r':r,'fn':m});
	}

	dynamic rule(String ns) => this.rules.get(ns);

	void removeRule(String ns){
		if(!this.rules.has(ns)) return null;
		this.rules.destroy(ns).clear();
	}

	void process(String data,Function m,Function g){
		Enums.eachAsync(this.rules.core,(e,i,o,fn){
			if(e['r'].hasMatch(data)) return fn(e);
			return fn(null);
		},(_,err){
			if(Valids.exist(err)) return m(err);
			return g(err);
		});
	}

	void destroy(){
		this.rules.onAll((v,k) => k.clear());
		this.rules.clear();
	}
}

class BassNS{
	Distributor procDist;
	MapDecorator fnMixes;
	MapDecorator varbars;
	MapDecorator scanned;
	SelectorRule seltypes;
	RuleSet extensions;
	StyleSet mixstyles;
	StyleSet styles;
	Switch strictKeys;
	String ns;

	static create(s,n) => new BassNS(s,n);

	BassNS(this.ns,this.extensions){
		this.strictKeys = Switch.create();
		this.varbars = MapDecorator.create();
		this.fnMixes = MapDecorator.create();
		this.scanned = MapDecorator.create();
		this.styles = StyleSet.create();
		this.seltypes = SelectorRule.create();
		this.mixstyles = StyleSet.create();
		this.procDist = new Distributor('${this.ns}-Distributor');

		this.strictKeys.switchOn();
		this.extensions.rule('mix',(val,bns){
			var m = val.split(','),mix = {};
			m.forEach((f){
				if(!bns.mixstyles.hasStyle(f)) return null;
				mix.addAll(bns.mixstyles.getMaps(f));
			});
			return mix;
		});

		this.extensions.rule('mixvar',(val,bns){
			var mix = {},prop,vard,m;
			val.split(',').forEach((f){
				m = f.split(':');
				prop = Enums.first(m);
				vard = Enums.second(m);
				if(m.length < 2 || m.length > 2 || !BassUtil.varrule.hasMatch(vard)) return null;
				mix[prop.toString()] = this.vars(Enums.second(vard.split('#')));
			});
			return mix;
		});


		this.seltypes.addRule('state',new RegExp(r'^:\S([\w\W]+)'),(s,d){
			return [s,d].join('');
		});

		this.seltypes.addRule('descendant',new RegExp(r'^>([\w\W]+)'),(s,d){
			return [s,'>',d.replaceAll('>','')].join(' ');
		});

		this.seltypes.addRule('space-descendants',new RegExp(r'^\s?\w+'),(s,d){
			return [s,d].join(' ');
		});

		this.seltypes.addRule('parent-descendant',new RegExp(r'&\s?([\w\W]+)'),(s,d){
			return d.replaceAll('&',s);
		});

		this.mixFn('identity',Funcs.identity);
		this.mixFn('format',(val,format) => [val,format].join(''));
		this.mixFn('%',(v) => this.fn('format',[v,'%']));
		this.mixFn('px',(v) => this.fn('format',[v,'px']));
		this.mixFn('rem',(v) => this.fn('format',[v,'rem']));
		this.mixFn('em',(v) => this.fn('format',[v,'em']));
	}

	void destroy(){
		this.varbars.clear();
		this.scanned.clear();
		this.strictKeys.close();
		this.procDist.destroy();
		this.seltypes.destroy();
		this.extensions.destroy();
		this.mixstyles.destroy();
		this.styles.destroy();
		this.ns = null;
	}

	Style retrieveStyle(String selector) => this.styles.get(selector);

	void updateSel(String selector,Map rules){
		if(!this.styles.hasStyle(selector)) return this.sel(selector,rules);
		var tmp = StyleSet.create();
		this.styleSelector(tmp,selector,rules,(s,c){
			s.styles.onAll((k,v){
				if(this.styles.hasStyle(k)) 
					return this.styles.get(k).rules.updateAll(v.rules);
					this.stles.style(k,v.maps);
			});
			tmp.destroy();
		});
	}

	void sel(String selector,Map rules) => this.styleSelector(this.styles,selector,rules);

	void styleSelector(StyleSet style,String selector,Map rules,[Function done]){
		Bass.debug.log('BassNS selMethod',{'selector': selector,'rules':rules});
		var nws,cleand = {};
		Enums.eachAsync(rules,(e,i,o,fn){
			if(this.strictKeys.on() && BassUtil.validkeys.hasMatch(i)) return  fn(null);
			if(e is Map){
				this.seltypes.process(i,(r){
					this.sel(r['fn'](selector,i),e);
				},(r){
					this.sel(i,e);
				});
				return fn(null);
			}

			cleand[i] = e;
			return fn(null);
		},(_,err){
			Bass.debug.log('BassNS sel $selector cleaned',cleand);
			style.style(selector,cleand);
			if(Valids.exist(done)) done(style,cleand);
		});
	}


	void mixVar(String id,dynamic n) => this.varbars.update(id,n);
	dynamic vars(String id) => this.varbars.get(id);
	bool hasVars(String id) => this.varbars.has(id);

	void bind(Function n) => this.procDist.on(n);
	void bindOnce(Function n) => this.procDist.once(n);
	void unbind(Function n) => this.procDist.off(n);
	void unbindOnce(Function n) => this.procDist.offOnce(n);
	void bindWhenDone(Function n) => this.procDist.whenDone(n);
	void unbindWhenDone(Function n) => this.procDist.offWhenDone(n);
	void clearListeners() => this.procDist.free();

	void scan(Function m){
		var f,rule;
		this.scanned.clear();
		Enums.eachAsync(this.styles.styles.core,(e,i,o,fn){
			this.scanned.update(i,{});
			f = this.scanned.get(i);
			e.maps.forEach((k,v){
				v = v.toString().replaceAll(BassUtil.escapeSeq,' ');
				if(!BassUtil.rules.hasMatch(k)) return f[k] = v;
				rule = BassUtil.rules.firstMatch(k).group(1);
				if(!this.extensions.hasRule(rule)) return null;
				return  f.addAll(Funcs.switchUnless(this.extensions.get(rule).process(v,this),{}));
			});
			fn(null);
		},(_,err){
			if(err) throw err;
			return m(new Map.from(this.scanned.core));
		});
	}

	BassFormatter css(){
		return BassFormatter.css(this);
	}

	dynamic compile(){
		this.scan((n) => this.procDist.emit(n));
	}

	dynamic fn(String n,[List a,Map m]){
		if(!this.fnMixes.has(n)) return null;
		return Funcs.dartApply(this.fnMixes.get(n),a,m);
	}

	void composeFn(String id,List<String> list,[int x]){
		this.mixFn(id,this._compose(list,x));
	}

	void mixFn(String id,Function m){
		id = id.replaceAll(r'/W+','');
		if(this.fnMixes.has(id)) return null;
		this.fnMixes.add(id,m);
	}

	void mix(String id,Map m){
		return this.mixstyles.style(id,m);
	}

    Function _compose(List<String> ops,[int x]){
    	var fns = Enums.map(ops,(e,i,o){
    		if(this.fnMixes.has(e)) return this.fnMixes.get(e);
    		return throw "$e does not exist in Mixins!";
		});
		return Funcs.single(fns,x);
	}
}

class BassUtil{
		static RegExp rules = new RegExp(r'^@([\w\W]+)');
		static RegExp varrule = new RegExp(r'^#([\w\W]+)');
		static RegExp escapeSeq = new RegExp(r'([\t|\n]+)');
		static RegExp validkeys = new RegExp(r'^([^\w\d&]+)$|^&$');
}

class BassFormatter{
	BassNS ns;
	Distributor chain;
	Function processor,_hidden;

	static create(fn,b) => new BassFormatter(fn,b);

	static css(BassNs ns){
		return BassFormatter.create((m){
			var pretty = Funcs.prettyPrint(m,null,null,'!|').split('!|');
			pretty[0] = '';
			pretty[pretty.length - 1] = '';
			return pretty.join('').replaceAll('",','";')
			.replaceAll('"','').replaceAll('},','}')
			.replaceAll(': {','{');
		},ns);	
	}

	BassFormatter(this.processor,this.ns){
		this.chain = Distributor.create('bassformatter');
		this.bindBass();
	}

	void bindBass(){
		this.ns.bind(this._hidden = (m) => this.chain.emit(this.processor(m)));
	}

	void unbindBass(){
		this.ns.unbind(this._hidden);
	}

	void bind(Function n) => this.chain.on(n);
	void bindOnce(Function n) => this.chain.once(n);
	void unbind(Function n) => this.chain.off(n);
	void unbindOnce(Function n) => this.chain.offOnce(n);
	void bindWhenDone(Function n) => this.chain.whenDone(n);
	void unbindWhenDone(Function n) => this.chain.offWhenDone(n);
	void clearListeners() => this.chain.free();

}

class Bass{
	RuleSet rules;
	MapDecorator namespace;

	static Log debug = Log.create(null,null,"BassLog#({tag}):\n\t{res}\n");
	static create() => new Bass();
	static Bass B = Bass.create();
	static RuleSet R = Bass.B.rules;

	static NS(String m) => Bass.B.ns(m);

	Bass([ruleset]){
		this.rules = RuleSet.create();
		this.namespace = MapDecorator.create();
	}

	BassNS ns(String n){
		if(this.namespace.has(n)) return this.namespace.get(n);
		var ng = BassNS.create(n,this.rules);
		this.namespace.add(n,ng);
		return ng;
	}

	void destroy(){
		this.rules.destroy();
		this.namespace.onAll((v,k) => k.destroy());
		this.namespace.clear();
	}
}