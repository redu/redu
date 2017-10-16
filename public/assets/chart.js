/*
 Highcharts JS v2.1.9 (2011-11-11)

 (c) 2009-2011 Torstein H?nsi

 License: www.highcharts.com/license
*/

(function(){function sa(a,b){var c;a||(a={});for(c in b)a[c]=b[c];return a}function ja(a,b){return parseInt(a,b||10)}function Sb(a){return typeof a==="string"}function Nb(a){return typeof a==="object"}function lc(a){return typeof a==="number"}function mc(a){return Fa.log(a)/Fa.LN10}function nc(a,b){for(var c=a.length;c--;)if(a[c]===b){a.splice(c,1);break}}function K(a){return a!==Wa&&a!==null}function Ga(a,b,c){var d,e;if(Sb(b))if(K(c))a.setAttribute(b,c);else{if(a&&a.getAttribute)e=a.getAttribute(b)}else if(K(b)&&
Nb(b))for(d in b)a.setAttribute(d,b[d]);return e}function zc(a){return Object.prototype.toString.call(a)==="[object Array]"?a:[a]}function A(){var a=arguments,b,c,d=a.length;for(b=0;b<d;b++){c=a[b];if(typeof c!=="undefined"&&c!==null)return c}}function Ja(a,b){if(Pc)if(b&&b.opacity!==Wa)b.filter="alpha(opacity="+b.opacity*100+")";sa(a.style,b)}function hb(a,b,c,d,e){a=ua.createElement(a);b&&sa(a,b);e&&Ja(a,{padding:0,border:jb,margin:0});c&&Ja(a,c);d&&d.appendChild(a);return a}function yb(a,b){var c=
function(){};c.prototype=new a;sa(c.prototype,b);return c}function Ed(a,b,c,d){var e=Xa.lang;a=a;var f=isNaN(b=bb(b))?2:b;b=c===undefined?e.decimalPoint:c;d=d===undefined?e.thousandsSep:d;e=a<0?"-":"";c=String(ja(a=bb(+a||0).toFixed(f)));var g=c.length>3?c.length%3:0;return e+(g?c.substr(0,g)+d:"")+c.substr(g).replace(/(\d{3})(?=\d)/g,"$1"+d)+(f?b+bb(a-c).toFixed(f).slice(2):"")}function Fd(a){var b={left:a.offsetLeft,top:a.offsetTop};for(a=a.offsetParent;a;){b.left+=a.offsetLeft;b.top+=a.offsetTop;
if(a!==ua.body&&a!==ua.documentElement){b.left-=a.scrollLeft;b.top-=a.scrollTop}a=a.offsetParent}return b}function Gd(){this.symbol=this.color=0}function fe(a,b,c,d,e,f,g){var h=g.x;g=g.y;var i=h-a+c-25,j=g-b+d+10,m;if(i<7)i=c+h+15;if(i+a>c+e){i-=i+a-(c+e);j-=b;m=true}if(j<5){j=5;if(m&&g>=j&&g<=j+b)j=g+b-5}else if(j+b>d+f)j=d+f-b-5;return{x:i,y:j}}function Hd(a,b){var c=a.length,d;for(d=0;d<c;d++)a[d].ss_i=d;a.sort(function(e,f){var g=b(e,f);return g===0?e.ss_i-f.ss_i:g});for(d=0;d<c;d++)delete a[d].ss_i}
function Ac(a){for(var b in a){a[b]&&a[b].destroy&&a[b].destroy();delete a[b]}}function oc(a,b){Bc=A(a,b.animation)}function Id(){var a=Xa.global.useUTC;Qc=a?Date.UTC:function(b,c,d,e,f,g){return(new Date(b,c,A(d,1),A(e,0),A(f,0),A(g,0))).getTime()};id=a?"getUTCMinutes":"getMinutes";jd=a?"getUTCHours":"getHours";kd=a?"getUTCDay":"getDay";Cc=a?"getUTCDate":"getDate";Rc=a?"getUTCMonth":"getMonth";Sc=a?"getUTCFullYear":"getFullYear";Jd=a?"setUTCMinutes":"setMinutes";Kd=a?"setUTCHours":"setHours";ld=
a?"setUTCDate":"setDate";Ld=a?"setUTCMonth":"setMonth";Md=a?"setUTCFullYear":"setFullYear"}function pc(a){Tc||(Tc=hb(Tb));a&&Tc.appendChild(a);Tc.innerHTML=""}function Uc(){}function Nd(a,b){function c(p){function q(k,n){this.pos=k;this.minor=n;this.isNew=true;n||this.addLabel()}function w(k){if(k){this.options=k;this.id=k.id}return this}function x(k,n,t,r){this.isNegative=n;this.options=k;this.x=t;this.stack=r;this.alignOptions={align:k.align||(va?n?"left":"right":"center"),verticalAlign:k.verticalAlign||
(va?"middle":n?"bottom":"top"),y:A(k.y,va?4:n?14:-6),x:A(k.x,va?n?-6:6:0)};this.textAlign=k.textAlign||(va?n?"right":"left":"center")}function V(){var k=[],n=[],t;pa=wa=null;zb=[];u(Ha,function(r){t=false;u(["xAxis","yAxis"],function(F){if(r.isCartesian&&(F==="xAxis"&&xa||F==="yAxis"&&!xa)&&(r.options[F]===o.index||r.options[F]===Wa&&o.index===0)){r[F]=I;zb.push(r);t=true}});if(!r.visible&&z.ignoreHiddenSeries)t=false;if(t){var J,E,Q,fa,ka,$;if(!xa){J=r.options.stacking;Vc=J==="percent";if(J){ka=
r.options.stack;fa=r.type+A(ka,"");$="-"+fa;r.stackKey=fa;E=k[fa]||[];k[fa]=E;Q=n[$]||[];n[$]=Q}if(Vc){pa=0;wa=99}}if(r.isCartesian){u(r.data,function(F){var O=F.x,S=F.y,aa=S<0,Eb=aa?Q:E,kb=aa?$:fa;if(pa===null)pa=wa=F[qa];if(xa)if(O>wa)wa=O;else{if(O<pa)pa=O}else if(K(S)){if(J)Eb[O]=K(Eb[O])?Eb[O]+S:S;S=Eb?Eb[O]:S;F=A(F.low,S);if(!Vc)if(S>wa)wa=S;else if(F<pa)pa=F;if(J){s[kb]||(s[kb]={});s[kb][O]||(s[kb][O]=new x(o.stackLabels,aa,O,ka));s[kb][O].setTotal(S)}}});if(/(area|column|bar)/.test(r.type)&&
!xa)if(pa>=0){pa=0;Od=true}else if(wa<0){wa=0;Pd=true}}}})}function N(k,n){var t,r;Fb=n?1:Fa.pow(10,lb(Fa.log(k)/Fa.LN10));t=k/Fb;if(!n){n=[1,2,2.5,5,10];if(o.allowDecimals===false||ca)if(Fb===1)n=[1,2,5,10];else if(Fb<=0.1)n=[1/Fb]}for(r=0;r<n.length;r++){k=n[r];if(t<=(n[r]+(n[r+1]||n[r]))/2)break}k*=Fb;return k}function ta(k){var n;n=k;Fb=A(Fb,Fa.pow(10,lb(Fa.log(Ta)/Fa.LN10)));if(Fb<1){n=W(1/Fb)*10;n=W(k*n)/n}return n}function da(){var k,n,t,r,J=o.tickInterval,E=o.tickPixelInterval;k=o.maxZoom||
(xa&&!K(o.min)&&!K(o.max)?tb(l.smallestInterval*5,wa-pa):null);ya=R?Da:Aa;if(Ub){t=l[xa?"xAxis":"yAxis"][o.linkedTo];r=t.getExtremes();ia=A(r.min,r.dataMin);ra=A(r.max,r.dataMax)}else{ia=A(Vb,o.min,pa);ra=A(Gb,o.max,wa)}if(ca){ia=mc(ia);ra=mc(ra)}if(ra-ia<k){r=(k-ra+ia)/2;ia=Ia(ia-r,A(o.min,ia-r),pa);ra=tb(ia+k,A(o.max,ia+k),wa)}if(!Ya&&!Vc&&!Ub&&K(ia)&&K(ra)){k=ra-ia||1;if(!K(o.min)&&!K(Vb)&&Qd&&(pa<0||!Od))ia-=k*Qd;if(!K(o.max)&&!K(Gb)&&Rd&&(wa>0||!Pd))ra+=k*Rd}Ta=ia===ra?1:Ub&&!J&&E===t.options.tickPixelInterval?
t.tickInterval:A(J,Ya?1:(ra-ia)*E/ya);if(!D&&!K(o.tickInterval))Ta=N(Ta);I.tickInterval=Ta;Wc=o.minorTickInterval==="auto"&&Ta?Ta/5:o.minorTickInterval;if(D){Ba=[];J=Xa.global.useUTC;var Q=1E3/ub,fa=6E4/ub,ka=36E5/ub;E=864E5/ub;k=6048E5/ub;r=2592E6/ub;var $=31556952E3/ub,F=[["second",Q,[1,2,5,10,15,30]],["minute",fa,[1,2,5,10,15,30]],["hour",ka,[1,2,3,4,6,8,12]],["day",E,[1,2]],["week",k,[1,2]],["month",r,[1,2,3,4,6]],["year",$,null]],O=F[6],S=O[1],aa=O[2];for(t=0;t<F.length;t++){O=F[t];S=O[1];aa=
O[2];if(F[t+1])if(Ta<=(S*aa[aa.length-1]+F[t+1][1])/2)break}if(S===$&&Ta<5*S)aa=[1,2,5];F=N(Ta/S,aa);aa=new Date(ia*ub);aa.setMilliseconds(0);if(S>=Q)aa.setSeconds(S>=fa?0:F*lb(aa.getSeconds()/F));if(S>=fa)aa[Jd](S>=ka?0:F*lb(aa[id]()/F));if(S>=ka)aa[Kd](S>=E?0:F*lb(aa[jd]()/F));if(S>=E)aa[ld](S>=r?1:F*lb(aa[Cc]()/F));if(S>=r){aa[Ld](S>=$?0:F*lb(aa[Rc]()/F));n=aa[Sc]()}if(S>=$){n-=n%F;aa[Md](n)}S===k&&aa[ld](aa[Cc]()-aa[kd]()+o.startOfWeek);t=1;n=aa[Sc]();Q=aa.getTime()/ub;fa=aa[Rc]();for(ka=aa[Cc]();Q<
ra&&t<Da;){Ba.push(Q);if(S===$)Q=Qc(n+t*F,0)/ub;else if(S===r)Q=Qc(n,fa+t*F)/ub;else if(!J&&(S===E||S===k))Q=Qc(n,fa,ka+t*F*(S===E?1:7));else Q+=S*F;t++}Ba.push(Q);Xc=o.dateTimeLabelFormats[O[0]]}else{t=ta(lb(ia/Ta)*Ta);n=ta(md(ra/Ta)*Ta);Ba=[];for(t=ta(t);t<=n;){Ba.push(t);t=ta(t+Ta)}}if(!Ub){if(Ya||xa&&l.hasColumn){n=(Ya?1:Ta)*0.5;if(Ya||!K(A(o.min,Vb)))ia-=n;if(Ya||!K(A(o.max,Gb)))ra+=n}n=Ba[0];t=Ba[Ba.length-1];if(o.startOnTick)ia=n;else ia>n&&Ba.shift();if(o.endOnTick)ra=t;else ra<t&&Ba.pop();
Ob||(Ob={x:0,y:0});if(!D&&Ba.length>Ob[qa])Ob[qa]=Ba.length}}function Ma(){var k,n;Dc=ia;Sd=ra;V();da();Hb=fb;fb=ya/(ra-ia||1);if(!xa)for(k in s)for(n in s[k])s[k][n].cum=s[k][n].total;if(!I.isDirty)I.isDirty=ia!==Dc||ra!==Sd}function za(k){k=(new w(k)).render();Pb.push(k);return k}function eb(){var k=o.title,n=o.stackLabels,t=o.alternateGridColor,r=o.lineWidth,J,E,Q=(J=l.hasRendered)&&K(Dc)&&!isNaN(Dc);E=zb.length&&K(ia)&&K(ra);ya=R?Da:Aa;fb=ya/(ra-ia||1);cc=R?X:vb;if(E||Ub){if(Wc&&!Ya)for(E=ia+
(Ba[0]-ia)%Wc;E<=ra;E+=Wc){Wb[E]||(Wb[E]=new q(E,true));Q&&Wb[E].isNew&&Wb[E].render(null,true);Wb[E].isActive=true;Wb[E].render()}u(Ba,function($,F){if(!Ub||$>=ia&&$<=ra){Q&&mb[$].isNew&&mb[$].render(F,true);mb[$].isActive=true;mb[$].render(F)}});t&&u(Ba,function($,F){if(F%2===0&&$<ra){dc[$]||(dc[$]=new w);dc[$].options={from:$,to:Ba[F+1]!==Wa?Ba[F+1]:ra,color:t};dc[$].render();dc[$].isActive=true}});J||u((o.plotLines||[]).concat(o.plotBands||[]),function($){Pb.push((new w($)).render())})}u([mb,
Wb,dc],function($){for(var F in $)if($[F].isActive)$[F].isActive=false;else{$[F].destroy();delete $[F]}});if(r){J=X+(Oa?Da:0)+la;E=cb-vb-(Oa?Aa:0)+la;J=ga.crispLine([Za,R?X:J,R?E:ea,Ka,R?$a-Ib:J,R?E:cb-vb],r);if(La)La.animate({d:J});else La=ga.path(J).attr({stroke:o.lineColor,"stroke-width":r,zIndex:7}).add()}if(ba){J=R?X:ea;r=ja(k.style.fontSize||12);J={low:J+(R?0:ya),middle:J+ya/2,high:J+(R?ya:0)}[k.align];r=(R?ea+Aa:X)+(R?1:-1)*(Oa?-1:1)*nd+(L===2?r:0);ba[ba.isNew?"attr":"animate"]({x:R?J:r+(Oa?
Da:0)+la+(k.x||0),y:R?r-(Oa?Aa:0)+la:J+(k.y||0)});ba.isNew=false}if(n&&n.enabled){var fa,ka;n=I.stackTotalGroup;if(!n)I.stackTotalGroup=n=ga.g("stack-labels").attr({visibility:Ab,zIndex:6}).translate(X,ea).add();for(fa in s){k=s[fa];for(ka in k)k[ka].render(n)}}I.isDirty=false}function ab(k){for(var n=Pb.length;n--;)Pb[n].id===k&&Pb[n].destroy()}var xa=p.isX,Oa=p.opposite,R=va?!xa:xa,L=R?Oa?0:2:Oa?1:3,s={},o=Ca(xa?Yc:od,[ge,he,Td,ie][L],p),I=this,ba,B=o.type,D=B==="datetime",ca=B==="logarithmic",
la=o.offset||0,qa=xa?"x":"y",ya,fb,Hb,cc=R?X:vb,G,ha,na,Ra,La,pa,wa,zb,Vb,Gb,ra=null,ia=null,Dc,Sd,Qd=o.minPadding,Rd=o.maxPadding,Ub=K(o.linkedTo),Od,Pd,Vc;B=o.events;var pd,Pb=[],Ta,Wc,Fb,Ba,mb={},Wb={},dc={},qc,rc,nd,Xc,Ya=o.categories,je=o.labels.formatter||function(){var k=this.value;return Xc?Zc(Xc,k):Ta%1E6===0?k/1E6+"M":Ta%1E3===0?k/1E3+"k":!Ya&&k>=1E3?Ed(k,0):k},$c=R&&o.labels.staggerLines,ec=o.reversed,fc=Ya&&o.tickmarkPlacement==="between"?0.5:0;q.prototype={addLabel:function(){var k=this.pos,
n=o.labels,t=!(k===ia&&!A(o.showFirstLabel,1)||k===ra&&!A(o.showLastLabel,0)),r=Ya&&R&&Ya.length&&!n.step&&!n.staggerLines&&!n.rotation&&Da/Ya.length||!R&&Da/2,J=Ya&&K(Ya[k])?Ya[k]:k,E=this.label;k=je.call({isFirst:k===Ba[0],isLast:k===Ba[Ba.length-1],dateTimeLabelFormat:Xc,value:ca?Fa.pow(10,J):J});r=r&&{width:Ia(1,W(r-2*(n.padding||10)))+Ua};r=sa(r,n.style);if(E===Wa)this.label=K(k)&&t&&n.enabled?ga.text(k,0,0,n.useHTML).attr({align:n.align,rotation:n.rotation}).css(r).add(na):null;else E&&E.attr({text:k}).css(r)},
getLabelSize:function(){var k=this.label;return k?(this.labelBBox=k.getBBox())[R?"height":"width"]:0},render:function(k,n){var t=!this.minor,r=this.label,J=this.pos,E=o.labels,Q=this.gridLine,fa=t?o.gridLineWidth:o.minorGridLineWidth,ka=t?o.gridLineColor:o.minorGridLineColor,$=t?o.gridLineDashStyle:o.minorGridLineDashStyle,F=this.mark,O=t?o.tickLength:o.minorTickLength,S=t?o.tickWidth:o.minorTickWidth||0,aa=t?o.tickColor:o.minorTickColor,Eb=t?o.tickPosition:o.minorTickPosition,kb=E.step,nb=n&&ad||
cb,Qb;Qb=R?G(J+fc,null,null,n)+cc:X+la+(Oa?(n&&qd||$a)-Ib-X:0);nb=R?nb-vb+la-(Oa?Aa:0):nb-G(J+fc,null,null,n)-cc;if(fa){J=ha(J+fc,fa,n);if(Q===Wa){Q={stroke:ka,"stroke-width":fa};if($)Q.dashstyle=$;if(t)Q.zIndex=1;this.gridLine=Q=fa?ga.path(J).attr(Q).add(Ra):null}!n&&Q&&J&&Q.animate({d:J})}if(S){if(Eb==="inside")O=-O;if(Oa)O=-O;t=ga.crispLine([Za,Qb,nb,Ka,Qb+(R?0:-O),nb+(R?O:0)],S);if(F)F.animate({d:t});else this.mark=ga.path(t).attr({stroke:aa,"stroke-width":S}).add(na)}if(r&&!isNaN(Qb)){Qb=Qb+
E.x-(fc&&R?fc*fb*(ec?-1:1):0);nb=nb+E.y-(fc&&!R?fc*fb*(ec?1:-1):0);K(E.y)||(nb+=ja(r.styles.lineHeight)*0.9-r.getBBox().height/2);if($c)nb+=k/(kb||1)%$c*16;if(kb)r[k%kb?"hide":"show"]();r[this.isNew?"attr":"animate"]({x:Qb,y:nb})}this.isNew=false},destroy:function(){Ac(this)}};w.prototype={render:function(){var k=this,n=k.options,t=n.label,r=k.label,J=n.width,E=n.to,Q=n.from,fa=n.value,ka,$=n.dashStyle,F=k.svgElem,O=[],S,aa,Eb=n.color;aa=n.zIndex;var kb=n.events;if(ca){Q=mc(Q);E=mc(E);fa=mc(fa)}if(J){O=
ha(fa,J);n={stroke:Eb,"stroke-width":J};if($)n.dashstyle=$}else if(K(Q)&&K(E)){Q=Ia(Q,ia);E=tb(E,ra);ka=ha(E);if((O=ha(Q))&&ka)O.push(ka[4],ka[5],ka[1],ka[2]);else O=null;n={fill:Eb}}else return;if(K(aa))n.zIndex=aa;if(F)if(O)F.animate({d:O},null,F.onGetPath);else{F.hide();F.onGetPath=function(){F.show()}}else if(O&&O.length){k.svgElem=F=ga.path(O).attr(n).add();if(kb){$=function(nb){F.on(nb,function(Qb){kb[nb].apply(k,[Qb])})};for(S in kb)$(S)}}if(t&&K(t.text)&&O&&O.length&&Da>0&&Aa>0){t=Ca({align:R&&
ka&&"center",x:R?!ka&&4:10,verticalAlign:!R&&ka&&"middle",y:R?ka?16:10:ka?6:-4,rotation:R&&!ka&&90},t);if(!r)k.label=r=ga.text(t.text,0,0).attr({align:t.textAlign||t.align,rotation:t.rotation,zIndex:aa}).css(t.style).add();ka=[O[1],O[4],A(O[6],O[1])];O=[O[2],O[5],A(O[7],O[2])];S=tb.apply(Fa,ka);aa=tb.apply(Fa,O);r.align(t,false,{x:S,y:aa,width:Ia.apply(Fa,ka)-S,height:Ia.apply(Fa,O)-aa});r.show()}else r&&r.hide();return k},destroy:function(){Ac(this);nc(Pb,this)}};x.prototype={destroy:function(){Ac(this)},
setTotal:function(k){this.cum=this.total=k},render:function(k){var n=this.options.formatter.call(this);if(this.label)this.label.attr({text:n,visibility:ob});else this.label=l.renderer.text(n,0,0).css(this.options.style).attr({align:this.textAlign,rotation:this.options.rotation,visibility:ob}).add(k)},setOffset:function(k,n){var t=this.isNegative,r=I.translate(this.total),J=I.translate(0);J=bb(r-J);var E=l.xAxis[0].translate(this.x)+k,Q=l.plotHeight;t={x:va?t?r:r-J:E,y:va?Q-E-n:t?Q-r-J:Q-r,width:va?
J:n,height:va?n:J};this.label&&this.label.align(this.alignOptions,null,t).attr({visibility:Ab})}};G=function(k,n,t,r,J){var E=1,Q=0,fa=r?Hb:fb;r=r?Dc:ia;fa||(fa=fb);if(t){E*=-1;Q=ya}if(ec){E*=-1;Q-=E*ya}if(n){if(ec)k=ya-k;k=k/fa+r;if(ca&&J)k=Fa.pow(10,k)}else{if(ca&&J)k=mc(k);k=E*(k-r)*fa+Q}return k};ha=function(k,n,t){var r,J,E;k=G(k,null,null,t);var Q=t&&ad||cb,fa=t&&qd||$a,ka;t=J=W(k+cc);r=E=W(Q-k-cc);if(isNaN(k))ka=true;else if(R){r=ea;E=Q-vb;if(t<X||t>X+Da)ka=true}else{t=X;J=fa-Ib;if(r<ea||r>
ea+Aa)ka=true}return ka?null:ga.crispLine([Za,t,r,Ka,J,E],n||0)};if(va&&xa&&ec===Wa)ec=true;sa(I,{addPlotBand:za,addPlotLine:za,adjustTickAmount:function(){if(Ob&&!D&&!Ya&&!Ub){var k=qc,n=Ba.length;qc=Ob[qa];if(n<qc){for(;Ba.length<qc;)Ba.push(ta(Ba[Ba.length-1]+Ta));fb*=(n-1)/(qc-1);ra=Ba[Ba.length-1]}if(K(k)&&qc!==k)I.isDirty=true}},categories:Ya,getExtremes:function(){return{min:ia,max:ra,dataMin:pa,dataMax:wa,userMin:Vb,userMax:Gb}},getPlotLinePath:ha,getThreshold:function(k){if(ia>k)k=ia;else if(ra<
k)k=ra;return G(k,0,1)},isXAxis:xa,options:o,plotLinesAndBands:Pb,getOffset:function(){var k=zb.length&&K(ia)&&K(ra),n=0,t=0,r=o.title,J=o.labels,E=[-1,1,1,-1][L],Q;if(!na){na=ga.g("axis").attr({zIndex:7}).add();Ra=ga.g("grid").attr({zIndex:1}).add()}rc=0;if(k||Ub){u(Ba,function(fa){if(mb[fa])mb[fa].addLabel();else mb[fa]=new q(fa);if(L===0||L===2||{1:"left",3:"right"}[L]===J.align)rc=Ia(mb[fa].getLabelSize(),rc)});if($c)rc+=($c-1)*16}else for(Q in mb){mb[Q].destroy();delete mb[Q]}if(r&&r.text){if(!ba){ba=
I.axisTitle=ga.text(r.text,0,0,r.useHTML).attr({zIndex:7,rotation:r.rotation||0,align:r.textAlign||{low:"left",middle:"center",high:"right"}[r.align]}).css(r.style).add();ba.isNew=true}n=ba.getBBox()[R?"height":"width"];t=A(r.margin,R?5:10)}la=E*(o.offset||Xb[L]);nd=rc+(L!==2&&rc&&E*o.labels[R?"y":"x"])+t;Xb[L]=Ia(Xb[L],nd+n+E*la)},render:eb,setCategories:function(k,n){I.categories=p.categories=Ya=k;u(zb,function(t){t.translate();t.setTooltipPoints(true)});I.isDirty=true;A(n,true)&&l.redraw()},setExtremes:function(k,
n,t,r){t=A(t,true);Pa(I,"setExtremes",{min:k,max:n},function(){Vb=k;Gb=n;t&&l.redraw(r)})},setScale:Ma,setTickPositions:da,translate:G,redraw:function(){Yb.resetTracker&&Yb.resetTracker();eb();u(Pb,function(k){k.render()});u(zb,function(k){k.isDirty=true})},removePlotBand:ab,removePlotLine:ab,reversed:ec,stacks:s,destroy:function(){var k;pb(I);for(k in s){Ac(s[k]);s[k]=null}if(I.stackTotalGroup)I.stackTotalGroup=I.stackTotalGroup.destroy();u([mb,Wb,dc,Pb],function(n){Ac(n)});u([La,na,Ra,ba],function(n){n&&
n.destroy()});La=na=Ra=ba=null}});for(pd in B)Qa(I,pd,B[pd]);Ma()}function d(){var p={};return{add:function(q,w,x,V){if(!p[q]){w=ga.text(w,0,0).css(a.toolbar.itemStyle).align({align:"right",x:-Ib-20,y:ea+30}).on("click",V).attr({align:"right",zIndex:20}).add();p[q]=w}},remove:function(q){pc(p[q].element);p[q]=null}}}function e(p){function q(){var B=this.points||zc(this),D=B[0].series.xAxis,ca=this.x;D=D&&D.options.type==="datetime";var la=Sb(ca)||D,qa;qa=la?['<span style="font-size: 10px">'+(D?Zc("%A, %b %e, %Y",
ca):ca)+"</span>"]:[];u(B,function(ya){qa.push(ya.point.tooltipFormatter(la))});return qa.join("<br/>")}function w(B,D){L=xa?B:(2*L+B)/3;s=xa?D:(s+D)/2;o.translate(L,s);rd=bb(B-L)>1||bb(D-s)>1?function(){w(B,D)}:null}function x(){if(!xa){var B=l.hoverPoints;o.hide();u(da,function(D){D&&D.hide()});B&&u(B,function(D){D.setState()});l.hoverPoints=null;xa=true}}var V,N=p.borderWidth,ta=p.crosshairs,da=[],Ma=p.style,za=p.shared,eb=ja(Ma.padding),ab=N+eb,xa=true,Oa,R,L=0,s=0;Ma.padding=0;var o=ga.g("tooltip").attr({zIndex:8}).add(),
I=ga.rect(ab,ab,0,0,p.borderRadius,N).attr({fill:p.backgroundColor,"stroke-width":N}).add(o).shadow(p.shadow),ba=ga.text("",eb+ab,ja(Ma.fontSize)+eb+ab,p.useHTML).attr({zIndex:1}).css(Ma).add(o);o.hide();return{shared:za,refresh:function(B){var D,ca,la,qa=0,ya={},fb=[];la=B.tooltipPos;D=p.formatter||q;ya=l.hoverPoints;if(za){ya&&u(ya,function(Hb){Hb.setState()});l.hoverPoints=B;u(B,function(Hb){Hb.setState(Bb);qa+=Hb.plotY;fb.push(Hb.getLabelConfig())});ca=B[0].plotX;qa=W(qa)/B.length;ya={x:B[0].category};
ya.points=fb;B=B[0]}else ya=B.getLabelConfig();ya=D.call(ya);V=B.series;ca=za?ca:B.plotX;qa=za?qa:B.plotY;D=W(la?la[0]:va?Da-qa:ca);ca=W(la?la[1]:va?Aa-ca:qa);la=za||!B.series.isCartesian||gc(D,ca);if(ya===false||!la)x();else{if(xa){o.show();xa=false}ba.attr({text:ya});la=ba.getBBox();Oa=la.width+2*eb;R=la.height+2*eb;I.attr({width:Oa,height:R,stroke:p.borderColor||B.color||V.color||"#606060"});D=fe(Oa,R,X,ea,Da,Aa,{x:D,y:ca});w(W(D.x-ab),W(D.y-ab))}if(ta){ta=zc(ta);for(D=ta.length;D--;){ca=B.series[D?
"yAxis":"xAxis"];if(ta[D]&&ca){ca=ca.getPlotLinePath(B[D?"y":"x"],1);if(da[D])da[D].attr({d:ca,visibility:Ab});else{la={"stroke-width":ta[D].width||1,stroke:ta[D].color||"#C0C0C0",zIndex:2};if(ta[D].dashStyle)la.dashstyle=ta[D].dashStyle;da[D]=ga.path(ca).attr(la).add()}}}}},hide:x,destroy:function(){u(da,function(B){B&&B.destroy()});u([I,ba,o],function(B){B&&B.destroy()});I=ba=o=null}}}function f(p){function q(L){var s,o=Ud&&ua.width/ua.body.scrollWidth-1,I,ba,B;L=L||db.event;if(!L.target)L.target=
L.srcElement;s=L.touches?L.touches.item(0):L;if(L.type!=="mousemove"||db.opera||o){Jb=Fd(oa);I=Jb.left;ba=Jb.top}if(Pc){B=L.x;s=L.y}else if(s.layerX===Wa){B=s.pageX-I;s=s.pageY-ba}else{B=L.layerX;s=L.layerY}if(o){B+=W((o+1)*I-I);s+=W((o+1)*ba-ba)}return sa(L,{chartX:B,chartY:s})}function w(L){var s={xAxis:[],yAxis:[]};u(Va,function(o){var I=o.translate,ba=o.isXAxis;s[ba?"xAxis":"yAxis"].push({axis:o,value:I((va?!ba:ba)?L.chartX-X:Aa-L.chartY+ea,true)})});return s}function x(){var L=l.hoverSeries,
s=l.hoverPoint;s&&s.onMouseOut();L&&L.onMouseOut();hc&&hc.hide();sd=null}function V(){if(za){var L={xAxis:[],yAxis:[]},s=za.getBBox(),o=s.x-X,I=s.y-ea;if(Ma){u(Va,function(ba){var B=ba.translate,D=ba.isXAxis,ca=va?!D:D,la=B(ca?o:Aa-I-s.height,true,0,0,1);B=B(ca?o+s.width:Aa-I,true,0,0,1);L[D?"xAxis":"yAxis"].push({axis:ba,min:tb(la,B),max:Ia(la,B)})});Pa(l,"selection",L,td)}za=za.destroy()}l.mouseIsDown=ud=Ma=false;pb(ua,Kb?"touchend":"mouseup",V)}function N(L){var s=K(L.pageX)?L.pageX:L.page.x;L=
K(L.pageX)?L.pageY:L.page.y;Jb&&!gc(s-Jb.left-X,L-Jb.top-ea)&&x()}var ta,da,Ma,za,eb=z.zoomType,ab=/x/.test(eb),xa=/y/.test(eb),Oa=ab&&!va||xa&&va,R=xa&&!va||ab&&va;bd=function(){if(Ec){Ec.translate(X,ea);va&&Ec.attr({width:l.plotWidth,height:l.plotHeight}).invert()}else l.trackerGroup=Ec=ga.g("tracker").attr({zIndex:9}).add()};bd();if(p.enabled)l.tooltip=hc=e(p);(function(){oa.onmousedown=function(s){s=q(s);!Kb&&s.preventDefault&&s.preventDefault();l.mouseIsDown=ud=true;ta=s.chartX;da=s.chartY;Qa(ua,
Kb?"touchend":"mouseup",V)};var L=function(s){if(!(s&&s.touches&&s.touches.length>1)){s=q(s);if(!Kb)s.returnValue=false;var o=s.chartX,I=s.chartY,ba=!gc(o-X,I-ea);Jb||(Jb=Fd(oa));if(Kb&&s.type==="touchstart")if(Ga(s.target,"isTracker"))l.runTrackerClick||s.preventDefault();else!ke&&!ba&&s.preventDefault();if(ba){if(o<X)o=X;else if(o>X+Da)o=X+Da;if(I<ea)I=ea;else if(I>ea+Aa)I=ea+Aa}if(ud&&s.type!=="touchstart"){Ma=Math.sqrt(Math.pow(ta-o,2)+Math.pow(da-I,2));if(Ma>10){if(sc&&(ab||xa)&&gc(ta-X,da-ea))za||
(za=ga.rect(X,ea,Oa?1:Da,R?1:Aa,0).attr({fill:z.selectionMarkerFill||"rgba(69,114,167,0.25)",zIndex:7}).add());if(za&&Oa){o=o-ta;za.attr({width:bb(o),x:(o>0?0:o)+ta})}if(za&&R){I=I-da;za.attr({height:bb(I),y:(I>0?0:I)+da})}}}else if(!ba){var B;I=l.hoverPoint;o=l.hoverSeries;var D,ca,la=$a,qa=va?s.chartY:s.chartX-X;if(hc&&p.shared){B=[];D=Ha.length;for(ca=0;ca<D;ca++)if(Ha[ca].visible&&Ha[ca].tooltipPoints.length){s=Ha[ca].tooltipPoints[qa];s._dist=bb(qa-s.plotX);la=tb(la,s._dist);B.push(s)}for(D=
B.length;D--;)B[D]._dist>la&&B.splice(D,1);if(B.length&&B[0].plotX!==sd){hc.refresh(B);sd=B[0].plotX}}if(o&&o.tracker)(s=o.tooltipPoints[qa])&&s!==I&&s.onMouseOver()}return ba||!sc}};oa.onmousemove=L;Qa(oa,"mouseleave",x);Qa(ua,"mousemove",N);oa.ontouchstart=function(s){if(ab||xa)oa.onmousedown(s);L(s)};oa.ontouchmove=L;oa.ontouchend=function(){Ma&&x()};oa.onclick=function(s){var o=l.hoverPoint;s=q(s);s.cancelBubble=true;if(!Ma)if(o&&Ga(s.target,"isTracker")){var I=o.plotX,ba=o.plotY;sa(o,{pageX:Jb.left+
X+(va?Da-ba:I),pageY:Jb.top+ea+(va?Aa-I:ba)});Pa(o.series,"click",sa(s,{point:o}));o.firePointEvent("click",s)}else{sa(s,w(s));gc(s.chartX-X,s.chartY-ea)&&Pa(l,"click",s)}Ma=false}})();Vd=setInterval(function(){rd&&rd()},32);sa(this,{zoomX:ab,zoomY:xa,resetTracker:x,destroy:function(){if(l.trackerGroup)l.trackerGroup=Ec=l.trackerGroup.destroy();pb(ua,"mousemove",N);oa.onclick=oa.onmousedown=oa.onmousemove=oa.ontouchstart=oa.ontouchend=oa.ontouchmove=null}})}function g(p){var q=p.type||z.type||z.defaultSeriesType,
w=wb[q],x=l.hasRendered;if(x)if(va&&q==="column")w=wb.bar;else if(!va&&q==="bar")w=wb.column;q=new w;q.init(l,p);if(!x&&q.inverted)va=true;if(q.isCartesian)sc=q.isCartesian;Ha.push(q);return q}function h(){z.alignTicks!==false&&u(Va,function(p){p.adjustTickAmount()});Ob=null}function i(p){var q=l.isDirtyLegend,w,x=l.isDirtyBox,V=Ha.length,N=V,ta=l.clipRect;for(oc(p,l);N--;){p=Ha[N];if(p.isDirty&&p.options.stacking){w=true;break}}if(w)for(N=V;N--;){p=Ha[N];if(p.options.stacking)p.isDirty=true}u(Ha,
function(da){if(da.isDirty){da.cleanData();da.getSegments();if(da.options.legendType==="point")q=true}});if(q&&Fc.renderLegend){Fc.renderLegend();l.isDirtyLegend=false}if(sc){if(!cd){Ob=null;u(Va,function(da){da.setScale()})}h();Gc();u(Va,function(da){if(da.isDirty||x){da.redraw();x=true}})}if(x){vd();bd();if(ta){Hc(ta);ta.animate({width:l.plotSizeX,height:l.plotSizeY})}}u(Ha,function(da){if(da.isDirty&&da.visible&&(!da.isCartesian||da.xAxis))da.redraw()});Yb&&Yb.resetTracker&&Yb.resetTracker();Pa(l,
"redraw")}function j(){var p=a.xAxis||{},q=a.yAxis||{},w;p=zc(p);u(p,function(x,V){x.index=V;x.isX=true});q=zc(q);u(q,function(x,V){x.index=V});Va=p.concat(q);l.xAxis=[];l.yAxis=[];Va=tc(Va,function(x){w=new c(x);l[w.isXAxis?"xAxis":"yAxis"].push(w);return w});h()}function m(p,q){uc=Ca(a.title,p);Ic=Ca(a.subtitle,q);u([["title",p,uc],["subtitle",q,Ic]],function(w){var x=w[0],V=l[x],N=w[1];w=w[2];if(V&&N)V=V.destroy();if(w&&w.text&&!V)l[x]=ga.text(w.text,0,0,w.useHTML).attr({align:w.align,"class":"highcharts-"+
x,zIndex:1}).css(w.style).add().align(w,false,Rb)})}function v(){qb=z.renderTo;Wd=vc+wd++;if(Sb(qb))qb=ua.getElementById(qb);qb.innerHTML="";if(!qb.offsetWidth){Zb=qb.cloneNode(true);Ja(Zb,{position:ic,top:"-9999px",display:""});ua.body.appendChild(Zb)}dd=(Zb||qb).offsetWidth;Jc=(Zb||qb).offsetHeight;l.chartWidth=$a=z.width||dd||600;l.chartHeight=cb=z.height||(Jc>19?Jc:400);l.container=oa=hb(Tb,{className:"highcharts-container"+(z.className?" "+z.className:""),id:Wd},sa({position:Xd,overflow:ob,width:$a+
Ua,height:cb+Ua,textAlign:"left"},z.style),Zb||qb);l.renderer=ga=z.forExport?new ed(oa,$a,cb,true):new fd(oa,$a,cb);var p,q;if(Yd&&oa.getBoundingClientRect){p=function(){Ja(oa,{left:0,top:0});q=oa.getBoundingClientRect();Ja(oa,{left:-(q.left-ja(q.left))+Ua,top:-(q.top-ja(q.top))+Ua})};p();Qa(db,"resize",p);Qa(l,"destroy",function(){pb(db,"resize",p)})}}function P(){function p(){var w=z.width||qb.offsetWidth,x=z.height||qb.offsetHeight;if(w&&x){if(w!==dd||x!==Jc){clearTimeout(q);q=setTimeout(function(){xd(w,
x,false)},100)}dd=w;Jc=x}}var q;Qa(db,"resize",p);Qa(l,"destroy",function(){pb(db,"resize",p)})}function T(){Pa(l,"endResize",null,function(){cd-=1})}function Y(){var p=a.labels,q=a.credits,w;m();Fc=l.legend=new le;Gc();u(Va,function(x){x.setTickPositions(true)});h();Gc();vd();sc&&u(Va,function(x){x.render()});if(!l.seriesGroup)l.seriesGroup=ga.g("series-group").attr({zIndex:3}).add();u(Ha,function(x){x.translate();x.setTooltipPoints();x.render()});p.items&&u(p.items,function(){var x=sa(p.style,this.style),
V=ja(x.left)+X,N=ja(x.top)+ea+12;delete x.left;delete x.top;ga.text(this.html,V,N).attr({zIndex:2}).css(x).add()});if(!l.toolbar)l.toolbar=d();if(q.enabled&&!l.credits){w=q.href;l.credits=ga.text(q.text,0,0).on("click",function(){if(w)location.href=w}).attr({align:q.position.align,zIndex:8}).css(q.style).add().align(q.position)}bd();l.hasRendered=true;if(Zb){qb.appendChild(oa);pc(Zb)}}function H(){var p,q=oa&&oa.parentNode;if(l!==null){Pa(l,"destroy");pb(db,"unload",H);pb(l);for(p=Va.length;p--;)Va[p]=
Va[p].destroy();for(p=Ha.length;p--;)Ha[p]=Ha[p].destroy();u(["title","subtitle","seriesGroup","clipRect","credits","tracker"],function(w){var x=l[w];if(x)l[w]=x.destroy()});u([wc,xc,Kc,Fc,hc,ga,Yb],function(w){w&&w.destroy&&w.destroy()});wc=xc=Kc=Fc=hc=ga=Yb=null;if(oa){oa.innerHTML="";pb(oa);q&&pc(oa);oa=null}clearInterval(Vd);for(p in l)delete l[p];l=null}}function U(){if(!Lc&&db==db.top&&ua.readyState!=="complete")ua.attachEvent("onreadystatechange",function(){ua.detachEvent("onreadystatechange",
U);ua.readyState==="complete"&&U()});else{v();yd();zd();u(a.series||[],function(p){g(p)});l.inverted=va=A(va,a.chart.inverted);j();l.render=Y;l.tracker=Yb=new f(a.tooltip);Y();Pa(l,"load");b&&b.apply(l,[l]);u(l.callbacks,function(p){p.apply(l,[l])})}}Yc=Ca(Yc,Xa.xAxis);od=Ca(od,Xa.yAxis);Xa.xAxis=Xa.yAxis=null;a=Ca(Xa,a);var z=a.chart,M=z.margin;M=Nb(M)?M:[M,M,M,M];var y=A(z.marginTop,M[0]),C=A(z.marginRight,M[1]),Z=A(z.marginBottom,M[2]),Sa=A(z.marginLeft,M[3]),Na=z.spacingTop,Ea=z.spacingRight,
gb=z.spacingBottom,Lb=z.spacingLeft,Rb,uc,Ic,ea,Ib,vb,X,Xb,qb,Zb,oa,Wd,dd,Jc,$a,cb,qd,ad,wc,Kc,Ad,xc,l=this,ke=(M=z.events)&&!!M.click,Bd,gc,hc,ud,jc,Zd,Cd,Aa,Da,Yb,Ec,bd,Fc,$b,ac,Jb,sc=z.showAxes,cd=0,Va=[],Ob,Ha=[],va,ga,rd,Vd,sd,vd,Gc,yd,zd,xd,td,$d,le=function(){function p(G,ha){var na=G.legendItem,Ra=G.legendLine,La=G.legendSymbol,pa=Oa.color,wa=ha?N.itemStyle.color:pa,zb=ha?G.color:pa;pa=ha?G.pointAttr[ib]:{stroke:pa,fill:pa};na&&na.css({fill:wa});Ra&&Ra.attr({stroke:zb});La&&La.attr(pa)}function q(G,
ha,na){var Ra=G.legendItem,La=G.legendLine,pa=G.legendSymbol;G=G.checkbox;Ra&&Ra.attr({x:ha,y:na});La&&La.translate(ha,na-4);pa&&pa.attr({x:ha+pa.xOff,y:na+pa.yOff});if(G){G.x=ha;G.y=na}}function w(){u(za,function(G){var ha=G.checkbox,na=qa.alignAttr;ha&&Ja(ha,{left:na.translateX+G.legendItemWidth+ha.x-40+Ua,top:na.translateY+ha.y-11+Ua})})}function x(G){var ha,na,Ra,La,pa=G.legendItem;La=G.series||G;var wa=La.options,zb=wa&&wa.borderWidth||0;if(!pa){La=/^(bar|pie|area|column)$/.test(La.type);G.legendItem=
pa=ga.text(N.labelFormatter.call(G),0,0).css(G.visible?ab:Oa).on("mouseover",function(){G.setState(Bb);pa.css(xa)}).on("mouseout",function(){pa.css(G.visible?ab:Oa);G.setState()}).on("click",function(){var Gb=function(){G.setVisible()};G.firePointEvent?G.firePointEvent("legendItemClick",null,Gb):Pa(G,"legendItemClick",null,Gb)}).attr({zIndex:2}).add(qa);if(!La&&wa&&wa.lineWidth){var Vb={"stroke-width":wa.lineWidth,zIndex:2};if(wa.dashStyle)Vb.dashstyle=wa.dashStyle;G.legendLine=ga.path([Za,-da-Ma,
0,Ka,-Ma,0]).attr(Vb).add(qa)}if(La)ha=ga.rect(na=-da-Ma,Ra=-11,da,12,2).attr({zIndex:3}).add(qa);else if(wa&&wa.marker&&wa.marker.enabled)ha=ga.symbol(G.symbol,na=-da/2-Ma,Ra=-4,wa.marker.radius).attr({zIndex:3}).add(qa);if(ha){ha.xOff=na+zb%2/2;ha.yOff=Ra+zb%2/2}G.legendSymbol=ha;p(G,G.visible);if(wa&&wa.showCheckbox){G.checkbox=hb("input",{type:"checkbox",checked:G.selected,defaultChecked:G.selected},N.itemCheckboxStyle,oa);Qa(G.checkbox,"click",function(Gb){Pa(G,"checkboxClick",{checked:Gb.target.checked},
function(){G.select()})})}}ha=pa.getBBox();na=G.legendItemWidth=N.itemWidth||da+Ma+ha.width+R;B=ha.height;if(ta&&o-s+na>(fb||$a-2*R-s)){o=s;I+=B}ba=I;q(G,o,I);if(ta)o+=na;else I+=B;ya=fb||Ia(ta?o-s:na,ya)}function V(){o=s;I=L;ba=ya=0;qa||(qa=ga.g("legend").attr({zIndex:7}).add());za=[];u(Hb,function(Ra){var La=Ra.options;if(La.showInLegend)za=za.concat(La.legendType==="point"?Ra.data:Ra)});Hd(za,function(Ra,La){return(Ra.options.legendIndex||0)-(La.options.legendIndex||0)});cc&&za.reverse();u(za,
x);$b=fb||ya;ac=ba-L+B;if(ca||la){$b+=2*R;ac+=2*R;if(D){if($b>0&&ac>0){D[D.isNew?"attr":"animate"](D.crisp(null,null,null,$b,ac));D.isNew=false}}else{D=ga.rect(0,0,$b,ac,N.borderRadius,ca||0).attr({stroke:N.borderColor,"stroke-width":ca||0,fill:la||jb}).add(qa).shadow(N.shadow);D.isNew=true}D[za.length?"show":"hide"]()}for(var G=["left","right","top","bottom"],ha,na=4;na--;){ha=G[na];if(eb[ha]&&eb[ha]!=="auto"){N[na<2?"align":"verticalAlign"]=ha;N[na<2?"x":"y"]=ja(eb[ha])*(na%2?-1:1)}}za.length&&
qa.align(sa(N,{width:$b,height:ac}),true,Rb);cd||w()}var N=l.options.legend;if(N.enabled){var ta=N.layout==="horizontal",da=N.symbolWidth,Ma=N.symbolPadding,za,eb=N.style,ab=N.itemStyle,xa=N.itemHoverStyle,Oa=N.itemHiddenStyle,R=ja(eb.padding),L=18,s=4+R+da+Ma,o,I,ba,B=0,D,ca=N.borderWidth,la=N.backgroundColor,qa,ya,fb=N.width,Hb=l.series,cc=N.reversed;V();Qa(l,"endResize",w);return{colorizeItem:p,destroyItem:function(G){var ha=G.checkbox;u(["legendItem","legendLine","legendSymbol"],function(na){G[na]&&
G[na].destroy()});ha&&pc(G.checkbox)},renderLegend:V,destroy:function(){if(D)D=D.destroy();if(qa)qa=qa.destroy()}}}};gc=function(p,q){return p>=0&&p<=Da&&q>=0&&q<=Aa};$d=function(){Pa(l,"selection",{resetSelection:true},td);l.toolbar.remove("zoom")};td=function(p){var q=Xa.lang,w=l.pointCount<100;l.toolbar.add("zoom",q.resetZoom,q.resetZoomTitle,$d);!p||p.resetSelection?u(Va,function(x){x.setExtremes(null,null,false,w)}):u(p.xAxis.concat(p.yAxis),function(x){var V=x.axis;if(l.tracker[V.isXAxis?"zoomX":
"zoomY"])V.setExtremes(x.min,x.max,false,w)});i()};Gc=function(){var p=a.legend,q=A(p.margin,10),w=p.x,x=p.y,V=p.align,N=p.verticalAlign,ta;yd();if((l.title||l.subtitle)&&!K(y))if(ta=Ia(l.title&&!uc.floating&&!uc.verticalAlign&&uc.y||0,l.subtitle&&!Ic.floating&&!Ic.verticalAlign&&Ic.y||0))ea=Ia(ea,ta+A(uc.margin,15)+Na);if(p.enabled&&!p.floating)if(V==="right")K(C)||(Ib=Ia(Ib,$b-w+q+Ea));else if(V==="left")K(Sa)||(X=Ia(X,$b+w+q+Lb));else if(N==="top")K(y)||(ea=Ia(ea,ac+x+q+Na));else if(N==="bottom")K(Z)||
(vb=Ia(vb,ac-x+q+gb));sc&&u(Va,function(da){da.getOffset()});K(Sa)||(X+=Xb[3]);K(y)||(ea+=Xb[0]);K(Z)||(vb+=Xb[2]);K(C)||(Ib+=Xb[1]);zd()};xd=function(p,q,w){var x=l.title,V=l.subtitle;cd+=1;oc(w,l);ad=cb;qd=$a;l.chartWidth=$a=W(p);l.chartHeight=cb=W(q);Ja(oa,{width:$a+Ua,height:cb+Ua});ga.setSize($a,cb,w);Da=$a-X-Ib;Aa=cb-ea-vb;Ob=null;u(Va,function(N){N.isDirty=true;N.setScale()});u(Ha,function(N){N.isDirty=true});l.isDirtyLegend=true;l.isDirtyBox=true;Gc();x&&x.align(null,null,Rb);V&&V.align(null,
null,Rb);i(w);ad=null;Pa(l,"resize");Bc===false?T():setTimeout(T,Bc&&Bc.duration||500)};zd=function(){l.plotLeft=X=W(X);l.plotTop=ea=W(ea);l.plotWidth=Da=W($a-X-Ib);l.plotHeight=Aa=W(cb-ea-vb);l.plotSizeX=va?Aa:Da;l.plotSizeY=va?Da:Aa;Rb={x:Lb,y:Na,width:$a-Lb-Ea,height:cb-Na-gb}};yd=function(){ea=A(y,Na);Ib=A(C,Ea);vb=A(Z,gb);X=A(Sa,Lb);Xb=[0,0,0,0]};vd=function(){var p=z.borderWidth||0,q=z.backgroundColor,w=z.plotBackgroundColor,x=z.plotBackgroundImage,V,N={x:X,y:ea,width:Da,height:Aa};V=p+(z.shadow?
8:0);if(p||q)if(wc)wc.animate(wc.crisp(null,null,null,$a-V,cb-V));else wc=ga.rect(V/2,V/2,$a-V,cb-V,z.borderRadius,p).attr({stroke:z.borderColor,"stroke-width":p,fill:q||jb}).add().shadow(z.shadow);if(w)if(Kc)Kc.animate(N);else Kc=ga.rect(X,ea,Da,Aa,0).attr({fill:w}).add().shadow(z.plotShadow);if(x)if(Ad)Ad.animate(N);else Ad=ga.image(x,X,ea,Da,Aa).add();if(z.plotBorderWidth)if(xc)xc.animate(xc.crisp(null,X,ea,Da,Aa));else xc=ga.rect(X,ea,Da,Aa,0,z.plotBorderWidth).attr({stroke:z.plotBorderColor,
"stroke-width":z.plotBorderWidth,zIndex:4}).add();l.isDirtyBox=false};Qa(db,"unload",H);z.reflow!==false&&Qa(l,"load",P);if(M)for(Bd in M)Qa(l,Bd,M[Bd]);l.options=a;l.series=Ha;l.addSeries=function(p,q,w){var x;if(p){oc(w,l);q=A(q,true);Pa(l,"addSeries",{options:p},function(){x=g(p);x.isDirty=true;l.isDirtyLegend=true;q&&l.redraw()})}return x};l.animation=A(z.animation,true);l.destroy=H;l.get=function(p){var q,w,x;for(q=0;q<Va.length;q++)if(Va[q].options.id===p)return Va[q];for(q=0;q<Ha.length;q++)if(Ha[q].options.id===
p)return Ha[q];for(q=0;q<Ha.length;q++){x=Ha[q].data;for(w=0;w<x.length;w++)if(x[w].id===p)return x[w]}return null};l.getSelectedPoints=function(){var p=[];u(Ha,function(q){p=p.concat(Dd(q.data,function(w){return w.selected}))});return p};l.getSelectedSeries=function(){return Dd(Ha,function(p){return p.selected})};l.hideLoading=function(){gd(jc,{opacity:0},{duration:a.loading.hideDuration,complete:function(){Ja(jc,{display:jb})}});Cd=false};l.isInsidePlot=gc;l.redraw=i;l.setSize=xd;l.setTitle=m;l.showLoading=
function(p){var q=a.loading;if(!jc){jc=hb(Tb,{className:"highcharts-loading"},sa(q.style,{left:X+Ua,top:ea+Ua,width:Da+Ua,height:Aa+Ua,zIndex:10,display:jb}),oa);Zd=hb("span",null,q.labelStyle,jc)}Zd.innerHTML=p||a.lang.loading;if(!Cd){Ja(jc,{opacity:0,display:""});gd(jc,{opacity:q.style.opacity},{duration:q.showDuration});Cd=true}};l.pointCount=0;l.counters=new Gd;U()}var ua=document,db=window,Fa=Math,W=Fa.round,lb=Fa.floor,md=Fa.ceil,Ia=Fa.max,tb=Fa.min,bb=Fa.abs,rb=Fa.cos,Cb=Fa.sin,kc=Fa.PI,ae=
kc*2/360,yc=navigator.userAgent,Pc=/msie/i.test(yc)&&!db.opera,Mc=ua.documentMode===8,Ud=/AppleWebKit/.test(yc),Yd=/Firefox/.test(yc),Lc=!!ua.createElementNS&&!!ua.createElementNS("http://www.w3.org/2000/svg","svg").createSVGRect,me=Yd&&parseInt(yc.split("Firefox/")[1],10)<4,fd,Kb=ua.documentElement.ontouchstart!==undefined,be={},wd=0,ub=1,Tc,Xa,Zc,Bc,Nc,Wa,Tb="div",ic="absolute",Xd="relative",ob="hidden",vc="highcharts-",Ab="visible",Ua="px",jb="none",Za="M",Ka="L",ce="rgba(192,192,192,"+(Lc?1.0E-6:
0.0020)+")",ib="",Bb="hover",Qc,id,jd,kd,Cc,Rc,Sc,Jd,Kd,ld,Ld,Md,ma=db.HighchartsAdapter,Db=ma||{},u=Db.each,Dd=Db.grep,tc=Db.map,Ca=Db.merge,Qa=Db.addEvent,pb=Db.removeEvent,Pa=Db.fireEvent,gd=Db.animate,Hc=Db.stop,wb={};Zc=function(a,b,c){function d(P){return P.toString().replace(/^([0-9])$/,"0$1")}if(!K(b)||isNaN(b))return"Invalid date";a=A(a,"%Y-%m-%d %H:%M:%S");b=new Date(b*ub);var e,f=b[jd](),g=b[kd](),h=b[Cc](),i=b[Rc](),j=b[Sc](),m=Xa.lang,v=m.weekdays;b={a:v[g].substr(0,3),A:v[g],d:d(h),
e:h,b:m.shortMonths[i],B:m.months[i],m:d(i+1),y:j.toString().substr(2,2),Y:j,H:d(f),I:d(f%12||12),l:f%12||12,M:d(b[id]()),p:f<12?"AM":"PM",P:f<12?"am":"pm",S:d(b.getSeconds())};for(e in b)a=a.replace("%"+e,b[e]);return c?a.substr(0,1).toUpperCase()+a.substr(1):a};Gd.prototype={wrapColor:function(a){if(this.color>=a)this.color=0},wrapSymbol:function(a){if(this.symbol>=a)this.symbol=0}};Nc={init:function(a,b,c){b=b||"";var d=a.shift,e=b.indexOf("C")>-1,f=e?7:3,g;b=b.split(" ");c=[].concat(c);var h,
i,j=function(m){for(g=m.length;g--;)m[g]===Za&&m.splice(g+1,0,m[g+1],m[g+2],m[g+1],m[g+2])};if(e){j(b);j(c)}if(a.isArea){h=b.splice(b.length-6,6);i=c.splice(c.length-6,6)}if(d){c=[].concat(c).splice(0,f).concat(c);a.shift=false}if(b.length)for(a=c.length;b.length<a;){d=[].concat(b).splice(b.length-f,f);if(e){d[f-6]=d[f-2];d[f-5]=d[f-1]}b=b.concat(d)}if(h){b=b.concat(h);c=c.concat(i)}return[b,c]},step:function(a,b,c,d){var e=[],f=a.length;if(c===1)e=d;else if(f===b.length&&c<1)for(;f--;){d=parseFloat(a[f]);
e[f]=isNaN(d)?a[f]:c*parseFloat(b[f]-d)+d}else e=b;return e}};ma&&ma.init&&ma.init(Nc);if(!ma&&db.jQuery){var Mb=jQuery;u=function(a,b){for(var c=0,d=a.length;c<d;c++)if(b.call(a[c],a[c],c,a)===false)return c};Dd=Mb.grep;tc=function(a,b){for(var c=[],d=0,e=a.length;d<e;d++)c[d]=b.call(a[d],a[d],d,a);return c};Ca=function(){var a=arguments;return Mb.extend(true,null,a[0],a[1],a[2],a[3])};Qa=function(a,b,c){Mb(a).bind(b,c)};pb=function(a,b,c){var d=ua.removeEventListener?"removeEventListener":"detachEvent";
if(ua[d]&&!a[d])a[d]=function(){};Mb(a).unbind(b,c)};Pa=function(a,b,c,d){var e=Mb.Event(b),f="detached"+b;sa(e,c);if(a[b]){a[f]=a[b];a[b]=null}Mb(a).trigger(e);if(a[f]){a[b]=a[f];a[f]=null}d&&!e.isDefaultPrevented()&&d(e)};gd=function(a,b,c){var d=Mb(a);if(b.d){a.toD=b.d;b.d=1}d.stop();d.animate(b,c)};Hc=function(a){Mb(a).stop()};Mb.extend(Mb.easing,{easeOutQuad:function(a,b,c,d,e){return-d*(b/=e)*(b-2)+c}});var de=jQuery.fx,ee=de.step;u(["cur","_default","width","height"],function(a,b){var c=b?
ee:de.prototype,d=c[a],e;if(d)c[a]=function(f){f=b?f:this;e=f.elem;return e.attr?e.attr(f.prop,f.now):d.apply(this,arguments)}});ee.d=function(a){var b=a.elem;if(!a.started){var c=Nc.init(b,b.d,b.toD);a.start=c[0];a.end=c[1];a.started=true}b.attr("d",Nc.step(a.start,a.end,a.pos,b.toD))}}ma={enabled:true,align:"center",x:0,y:15,style:{color:"#666",fontSize:"11px",lineHeight:"14px"}};Xa={colors:["#4572A7","#AA4643","#89A54E","#80699B","#3D96AE","#DB843D","#92A8CD","#A47D7C","#B5CA92"],symbols:["circle",
"diamond","square","triangle","triangle-down"],lang:{loading:"Loading...",months:["January","February","March","April","May","June","July","August","September","October","November","December"],shortMonths:["Jan","Feb","Mar","Apr","May","June","Jul","Aug","Sep","Oct","Nov","Dec"],weekdays:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],decimalPoint:".",resetZoom:"Reset zoom",resetZoomTitle:"Reset zoom level 1:1",thousandsSep:","},global:{useUTC:true},chart:{borderColor:"#4572A7",
borderRadius:5,defaultSeriesType:"line",ignoreHiddenSeries:true,spacingTop:10,spacingRight:10,spacingBottom:15,spacingLeft:10,style:{fontFamily:'"Lucida Grande", "Lucida Sans Unicode", Verdana, Arial, Helvetica, sans-serif',fontSize:"12px"},backgroundColor:"#FFFFFF",plotBorderColor:"#C0C0C0"},title:{text:"Chart title",align:"center",y:15,style:{color:"#3E576F",fontSize:"16px"}},subtitle:{text:"",align:"center",y:30,style:{color:"#6D869F"}},plotOptions:{line:{allowPointSelect:false,showCheckbox:false,
animation:{duration:1E3},events:{},lineWidth:2,shadow:true,marker:{enabled:true,lineWidth:0,radius:4,lineColor:"#FFFFFF",states:{hover:{},select:{fillColor:"#FFFFFF",lineColor:"#000000",lineWidth:2}}},point:{events:{}},dataLabels:Ca(ma,{enabled:false,y:-6,formatter:function(){return this.y}}),showInLegend:true,states:{hover:{marker:{}},select:{marker:{}}},stickyTracking:true}},labels:{style:{position:ic,color:"#3E576F"}},legend:{enabled:true,align:"center",layout:"horizontal",labelFormatter:function(){return this.name},
borderWidth:1,borderColor:"#909090",borderRadius:5,shadow:false,style:{padding:"5px"},itemStyle:{cursor:"pointer",color:"#3E576F"},itemHoverStyle:{cursor:"pointer",color:"#000000"},itemHiddenStyle:{color:"#C0C0C0"},itemCheckboxStyle:{position:ic,width:"13px",height:"13px"},symbolWidth:16,symbolPadding:5,verticalAlign:"bottom",x:0,y:0},loading:{hideDuration:100,labelStyle:{fontWeight:"bold",position:Xd,top:"1em"},showDuration:100,style:{position:ic,backgroundColor:"white",opacity:0.5,textAlign:"center"}},
tooltip:{enabled:true,backgroundColor:"rgba(255, 255, 255, .85)",borderWidth:2,borderRadius:5,shadow:true,snap:Kb?25:10,style:{color:"#333333",fontSize:"12px",padding:"5px",whiteSpace:"nowrap"}},toolbar:{itemStyle:{color:"#4572A7",cursor:"pointer"}},credits:{enabled:true,text:"Highcharts.com",href:"http://www.highcharts.com",position:{align:"right",x:-10,verticalAlign:"bottom",y:-5},style:{cursor:"pointer",color:"#909090",fontSize:"10px"}}};var Yc={dateTimeLabelFormats:{second:"%H:%M:%S",minute:"%H:%M",
hour:"%H:%M",day:"%e. %b",week:"%e. %b",month:"%b '%y",year:"%Y"},endOnTick:false,gridLineColor:"#C0C0C0",labels:ma,lineColor:"#C0D0E0",lineWidth:1,max:null,min:null,minPadding:0.01,maxPadding:0.01,minorGridLineColor:"#E0E0E0",minorGridLineWidth:1,minorTickColor:"#A0A0A0",minorTickLength:2,minorTickPosition:"outside",startOfWeek:1,startOnTick:false,tickColor:"#C0D0E0",tickLength:5,tickmarkPlacement:"between",tickPixelInterval:100,tickPosition:"outside",tickWidth:1,title:{align:"middle",style:{color:"#6D869F",
fontWeight:"bold"}},type:"linear"},od=Ca(Yc,{endOnTick:true,gridLineWidth:1,tickPixelInterval:72,showLastLabel:true,labels:{align:"right",x:-8,y:3},lineWidth:0,maxPadding:0.05,minPadding:0.05,startOnTick:true,tickWidth:0,title:{rotation:270,text:"Y-values"},stackLabels:{enabled:false,formatter:function(){return this.total},style:ma.style}}),ie={labels:{align:"right",x:-8,y:null},title:{rotation:270}},he={labels:{align:"left",x:8,y:null},title:{rotation:90}},Td={labels:{align:"center",x:0,y:14},title:{rotation:0}},
ge=Ca(Td,{labels:{y:-5}}),xb=Xa.plotOptions;ma=xb.line;xb.spline=Ca(ma);xb.scatter=Ca(ma,{lineWidth:0,states:{hover:{lineWidth:0}}});xb.area=Ca(ma,{});xb.areaspline=Ca(xb.area);xb.column=Ca(ma,{borderColor:"#FFFFFF",borderWidth:1,borderRadius:0,groupPadding:0.2,marker:null,pointPadding:0.1,minPointLength:0,states:{hover:{brightness:0.1,shadow:false},select:{color:"#C0C0C0",borderColor:"#000000",shadow:false}},dataLabels:{y:null,verticalAlign:null}});xb.bar=Ca(xb.column,{dataLabels:{align:"left",x:5,
y:0}});xb.pie=Ca(ma,{borderColor:"#FFFFFF",borderWidth:1,center:["50%","50%"],colorByPoint:true,dataLabels:{distance:30,enabled:true,formatter:function(){return this.point.name},y:5},legendType:"point",marker:null,size:"75%",showInLegend:false,slicedOffset:10,states:{hover:{brightness:0.1,shadow:false}}});Id();var bc=function(a){var b=[],c;(function(d){if(c=/rgba\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]?(?:\.[0-9]+)?)\s*\)/.exec(d))b=[ja(c[1]),ja(c[2]),ja(c[3]),parseFloat(c[4],
10)];else if(c=/#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(d))b=[ja(c[1],16),ja(c[2],16),ja(c[3],16),1]})(a);return{get:function(d){return b&&!isNaN(b[0])?d==="rgb"?"rgb("+b[0]+","+b[1]+","+b[2]+")":d==="a"?b[3]:"rgba("+b.join(",")+")":a},brighten:function(d){if(lc(d)&&d!==0){var e;for(e=0;e<3;e++){b[e]+=ja(d*255);if(b[e]<0)b[e]=0;if(b[e]>255)b[e]=255}}return this},setOpacity:function(d){b[3]=d;return this}}};Uc.prototype={init:function(a,b){this.element=ua.createElementNS("http://www.w3.org/2000/svg",
b);this.renderer=a},animate:function(a,b,c){if(b=A(b,Bc,true)){b=Ca(b);if(c)b.complete=c;gd(this,a,b)}else{this.attr(a);c&&c()}},attr:function(a,b){var c,d,e,f,g=this.element,h=g.nodeName,i=this.renderer,j,m=this.shadows,v=this.htmlNode,P,T=this;if(Sb(a)&&K(b)){c=a;a={};a[c]=b}if(Sb(a)){c=a;if(h==="circle")c={x:"cx",y:"cy"}[c]||c;else if(c==="strokeWidth")c="stroke-width";T=Ga(g,c)||this[c]||0;if(c!=="d"&&c!=="visibility")T=parseFloat(T)}else for(c in a){j=false;d=a[c];if(c==="d"){if(d&&d.join)d=
d.join(" ");if(/(NaN| {2}|^$)/.test(d))d="M 0 0";this.d=d}else if(c==="x"&&h==="text"){for(e=0;e<g.childNodes.length;e++){f=g.childNodes[e];Ga(f,"x")===Ga(g,"x")&&Ga(f,"x",d)}if(this.rotation)Ga(g,"transform","rotate("+this.rotation+" "+d+" "+ja(a.y||Ga(g,"y"))+")")}else if(c==="fill")d=i.color(d,g,c);else if(h==="circle"&&(c==="x"||c==="y"))c={x:"cx",y:"cy"}[c]||c;else if(c==="translateX"||c==="translateY"||c==="rotation"||c==="verticalAlign"){this[c]=d;this.updateTransform();j=true}else if(c===
"stroke")d=i.color(d,g,c);else if(c==="dashstyle"){c="stroke-dasharray";d=d&&d.toLowerCase();if(d==="solid")d=jb;else if(d){d=d.replace("shortdashdotdot","3,1,1,1,1,1,").replace("shortdashdot","3,1,1,1").replace("shortdot","1,1,").replace("shortdash","3,1,").replace("longdash","8,3,").replace(/dot/g,"1,3,").replace("dash","4,3,").replace(/,$/,"").split(",");for(e=d.length;e--;)d[e]=ja(d[e])*a["stroke-width"];d=d.join(",")}}else if(c==="isTracker")this[c]=d;else if(c==="width")d=ja(d);else if(c===
"align"){c="text-anchor";d={left:"start",center:"middle",right:"end"}[d]}else if(c==="title"){e=ua.createElementNS("http://www.w3.org/2000/svg","title");e.appendChild(ua.createTextNode(d));g.appendChild(e)}if(c==="strokeWidth")c="stroke-width";if(Ud&&c==="stroke-width"&&d===0)d=1.0E-6;if(this.symbolName&&/^(x|y|r|start|end|innerR)/.test(c)){if(!P){this.symbolAttr(a);P=true}j=true}if(m&&/^(width|height|visibility|x|y|d)$/.test(c))for(e=m.length;e--;)Ga(m[e],c,d);if((c==="width"||c==="height")&&h===
"rect"&&d<0)d=0;if(c==="text"){this.textStr=d;this.added&&i.buildText(this)}else j||Ga(g,c,d);if(v&&(c==="x"||c==="y"||c==="translateX"||c==="translateY"||c==="visibility")){e=v.length?v:[this];f=e.length;var Y;for(Y=0;Y<f;Y++){v=e[Y];j=v.getBBox();v=v.htmlNode;Ja(v,sa(this.styles,{left:j.x+(this.translateX||0)+Ua,top:j.y+(this.translateY||0)+Ua}));c==="visibility"&&Ja(v,{visibility:d})}}}return T},symbolAttr:function(a){var b=this;u(["x","y","r","start","end","width","height","innerR"],function(c){b[c]=
A(a[c],b[c])});b.attr({d:b.renderer.symbols[b.symbolName](W(b.x*2)/2,W(b.y*2)/2,b.r,{start:b.start,end:b.end,width:b.width,height:b.height,innerR:b.innerR})})},clip:function(a){return this.attr("clip-path","url("+this.renderer.url+"#"+a.id+")")},crisp:function(a,b,c,d,e){var f,g={},h={},i;a=a||this.strokeWidth||0;i=a%2/2;h.x=lb(b||this.x||0)+i;h.y=lb(c||this.y||0)+i;h.width=lb((d||this.width||0)-2*i);h.height=lb((e||this.height||0)-2*i);h.strokeWidth=a;for(f in h)if(this[f]!==h[f])this[f]=g[f]=h[f];
return g},css:function(a){var b=this.element;b=a&&a.width&&b.nodeName==="text";var c,d="",e=function(f,g){return"-"+g.toLowerCase()};if(a&&a.color)a.fill=a.color;this.styles=a=sa(this.styles,a);if(Pc&&!Lc){b&&delete a.width;Ja(this.element,a)}else{for(c in a)d+=c.replace(/([A-Z])/g,e)+":"+a[c]+";";this.attr({style:d})}b&&this.added&&this.renderer.buildText(this);return this},on:function(a,b){var c=b;if(Kb&&a==="click"){a="touchstart";c=function(d){d.preventDefault();b()}}this.element["on"+a]=c;return this},
translate:function(a,b){return this.attr({translateX:a,translateY:b})},invert:function(){this.inverted=true;this.updateTransform();return this},updateTransform:function(){var a=this.translateX||0,b=this.translateY||0,c=this.inverted,d=this.rotation,e=[];if(c){a+=this.attr("width");b+=this.attr("height")}if(a||b)e.push("translate("+a+","+b+")");if(c)e.push("rotate(90) scale(-1,1)");else d&&e.push("rotate("+d+" "+this.x+" "+this.y+")");e.length&&Ga(this.element,"transform",e.join(" "))},toFront:function(){var a=
this.element;a.parentNode.appendChild(a);return this},align:function(a,b,c){if(a){this.alignOptions=a;this.alignByTranslate=b;c||this.renderer.alignedObjects.push(this)}else{a=this.alignOptions;b=this.alignByTranslate}c=A(c,this.renderer);var d=a.align,e=a.verticalAlign,f=(c.x||0)+(a.x||0),g=(c.y||0)+(a.y||0),h={};if(/^(right|center)$/.test(d))f+=(c.width-(a.width||0))/{right:1,center:2}[d];h[b?"translateX":"x"]=W(f);if(/^(bottom|middle)$/.test(e))g+=(c.height-(a.height||0))/({bottom:1,middle:2}[e]||
1);h[b?"translateY":"y"]=W(g);this[this.placed?"animate":"attr"](h);this.placed=true;this.alignAttr=h;return this},getBBox:function(){var a,b,c,d=this.rotation,e=d*ae;try{a=sa({},this.element.getBBox())}catch(f){a={width:0,height:0}}b=a.width;c=a.height;if(d){a.width=bb(c*Cb(e))+bb(b*rb(e));a.height=bb(c*rb(e))+bb(b*Cb(e))}return a},show:function(){return this.attr({visibility:Ab})},hide:function(){return this.attr({visibility:ob})},add:function(a){var b=this.renderer,c=a||b,d=c.element||b.box,e=
d.childNodes,f=this.element,g=Ga(f,"zIndex");this.parentInverted=a&&a.inverted;this.textStr!==undefined&&b.buildText(this);if(a&&this.htmlNode){if(!a.htmlNode)a.htmlNode=[];a.htmlNode.push(this)}if(g){c.handleZ=true;g=ja(g)}if(c.handleZ)for(c=0;c<e.length;c++){a=e[c];b=Ga(a,"zIndex");if(a!==f&&(ja(b)>g||!K(g)&&K(b))){d.insertBefore(f,a);return this}}d.appendChild(f);this.added=true;return this},safeRemoveChild:function(a){var b=a.parentNode;b&&b.removeChild(a)},destroy:function(){var a=this,b=a.element||
{},c=a.shadows,d,e;b.onclick=b.onmouseout=b.onmouseover=b.onmousemove=null;Hc(a);if(a.clipPath)a.clipPath=a.clipPath.destroy();if(a.stops){for(e=0;e<a.stops.length;e++)a.stops[e]=a.stops[e].destroy();a.stops=null}a.safeRemoveChild(b);c&&u(c,function(f){a.safeRemoveChild(f)});nc(a.renderer.alignedObjects,a);for(d in a)delete a[d];return null},empty:function(){for(var a=this.element,b=a.childNodes,c=b.length;c--;)a.removeChild(b[c])},shadow:function(a,b){var c=[],d,e,f=this.element,g=this.parentInverted?
"(-1,-1)":"(1,1)";if(a){for(d=1;d<=3;d++){e=f.cloneNode(true);Ga(e,{isShadow:"true",stroke:"rgb(0, 0, 0)","stroke-opacity":0.05*d,"stroke-width":7-2*d,transform:"translate"+g,fill:jb});b?b.element.appendChild(e):f.parentNode.insertBefore(e,f);c.push(e)}this.shadows=c}return this}};var ed=function(){this.init.apply(this,arguments)};ed.prototype={Element:Uc,init:function(a,b,c,d){var e=location,f;f=this.createElement("svg").attr({xmlns:"http://www.w3.org/2000/svg",version:"1.1"});a.appendChild(f.element);
this.box=f.element;this.boxWrapper=f;this.alignedObjects=[];this.url=Pc?"":e.href.replace(/#.*?$/,"");this.defs=this.createElement("defs").add();this.forExport=d;this.gradients=[];this.setSize(b,c,false)},destroy:function(){var a,b=this.gradients,c=this.defs;this.box=null;this.boxWrapper=this.boxWrapper.destroy();if(b){for(a=0;a<b.length;a++)this.gradients[a]=b[a].destroy();this.gradients=null}if(c)this.defs=c.destroy();return this.alignedObjects=null},createElement:function(a){var b=new this.Element;
b.init(this,a);return b},buildText:function(a){for(var b=a.element,c=A(a.textStr,"").toString().replace(/<(b|strong)>/g,'<span style="font-weight:bold">').replace(/<(i|em)>/g,'<span style="font-style:italic">').replace(/<a/g,"<span").replace(/<\/(b|strong|i|em|a)>/g,"</span>").split(/<br.*?>/g),d=b.childNodes,e=/style="([^"]+)"/,f=/href="([^"]+)"/,g=Ga(b,"x"),h=a.styles,i=h&&a.useHTML&&!this.forExport,j=a.htmlNode,m=h&&ja(h.width),v=h&&h.lineHeight,P,T=d.length;T--;)b.removeChild(d[T]);m&&!a.added&&
this.box.appendChild(b);u(c,function(Y,H){var U,z=0,M;Y=Y.replace(/<span/g,"|||<span").replace(/<\/span>/g,"</span>|||");U=Y.split("|||");u(U,function(y){if(y!==""||U.length===1){var C={},Z=ua.createElementNS("http://www.w3.org/2000/svg","tspan");e.test(y)&&Ga(Z,"style",y.match(e)[1].replace(/(;| |^)color([ :])/,"$1fill$2"));if(f.test(y)){Ga(Z,"onclick",'location.href="'+y.match(f)[1]+'"');Ja(Z,{cursor:"pointer"})}y=(y.replace(/<(.|\n)*?>/g,"")||" ").replace(/&lt;/g,"<").replace(/&gt;/g,">");Z.appendChild(ua.createTextNode(y));
if(z)C.dx=3;else C.x=g;if(!z){if(H){!Lc&&a.renderer.forExport&&Ja(Z,{display:"block"});M=db.getComputedStyle&&ja(db.getComputedStyle(P,null).getPropertyValue("line-height"));if(!M||isNaN(M))M=v||P.offsetHeight||18;Ga(Z,"dy",M)}P=Z}Ga(Z,C);b.appendChild(Z);z++;if(m){y=y.replace(/-/g,"- ").split(" ");for(var Sa,Na=[];y.length||Na.length;){Sa=b.getBBox().width;C=Sa>m;if(!C||y.length===1){y=Na;Na=[];if(y.length){Z=ua.createElementNS("http://www.w3.org/2000/svg","tspan");Ga(Z,{dy:v||16,x:g});b.appendChild(Z);
if(Sa>m)m=Sa}}else{Z.removeChild(Z.firstChild);Na.unshift(y.pop())}y.length&&Z.appendChild(ua.createTextNode(y.join(" ").replace(/- /g,"-")))}}}})});if(i){if(!j)j=a.htmlNode=hb("span",null,sa(h,{position:ic,top:0,left:0}),this.box.parentNode);j.innerHTML=a.textStr;for(T=d.length;T--;)d[T].style.visibility=ob}},crispLine:function(a,b){if(a[1]===a[4])a[1]=a[4]=W(a[1])+b%2/2;if(a[2]===a[5])a[2]=a[5]=W(a[2])+b%2/2;return a},path:function(a){return this.createElement("path").attr({d:a,fill:jb})},circle:function(a,
b,c){a=Nb(a)?a:{x:a,y:b,r:c};return this.createElement("circle").attr(a)},arc:function(a,b,c,d,e,f){if(Nb(a)){b=a.y;c=a.r;d=a.innerR;e=a.start;f=a.end;a=a.x}return this.symbol("arc",a||0,b||0,c||0,{innerR:d||0,start:e||0,end:f||0})},rect:function(a,b,c,d,e,f){if(Nb(a)){b=a.y;c=a.width;d=a.height;e=a.r;f=a.strokeWidth;a=a.x}e=this.createElement("rect").attr({rx:e,ry:e,fill:jb});return e.attr(e.crisp(f,a,b,Ia(c,0),Ia(d,0)))},setSize:function(a,b,c){var d=this.alignedObjects,e=d.length;this.width=a;
this.height=b;for(this.boxWrapper[A(c,true)?"animate":"attr"]({width:a,height:b});e--;)d[e].align()},g:function(a){var b=this.createElement("g");return K(a)?b.attr({"class":vc+a}):b},image:function(a,b,c,d,e){var f={preserveAspectRatio:jb};arguments.length>1&&sa(f,{x:b,y:c,width:d,height:e});f=this.createElement("image").attr(f);f.element.setAttributeNS?f.element.setAttributeNS("http://www.w3.org/1999/xlink","href",a):f.element.setAttribute("hc-svg-href",a);return f},symbol:function(a,b,c,d,e){var f,
g=this.symbols[a];g=g&&g(W(b),W(c),d,e);var h=/^url\((.*?)\)$/,i;if(g){f=this.path(g);sa(f,{symbolName:a,x:b,y:c,r:d});e&&sa(f,e)}else if(h.test(a)){var j=function(m,v){m.attr({width:v[0],height:v[1]}).translate(-W(v[0]/2),-W(v[1]/2))};i=a.match(h)[1];a=be[i];f=this.image(i).attr({x:b,y:c});if(a)j(f,a);else{f.attr({width:0,height:0});hb("img",{onload:function(){j(f,be[i]=[this.width,this.height])},src:i})}}else f=this.circle(b,c,d);return f},symbols:{square:function(a,b,c){c=0.707*c;return[Za,a-c,
b-c,Ka,a+c,b-c,a+c,b+c,a-c,b+c,"Z"]},triangle:function(a,b,c){return[Za,a,b-1.33*c,Ka,a+c,b+0.67*c,a-c,b+0.67*c,"Z"]},"triangle-down":function(a,b,c){return[Za,a,b+1.33*c,Ka,a-c,b-0.67*c,a+c,b-0.67*c,"Z"]},diamond:function(a,b,c){return[Za,a,b-c,Ka,a+c,b,a,b+c,a-c,b,"Z"]},arc:function(a,b,c,d){var e=d.start,f=d.end-1.0E-6,g=d.innerR,h=rb(e),i=Cb(e),j=rb(f);f=Cb(f);d=d.end-e<kc?0:1;return[Za,a+c*h,b+c*i,"A",c,c,0,d,1,a+c*j,b+c*f,Ka,a+g*j,b+g*f,"A",g,g,0,d,0,a+g*h,b+g*i,"Z"]}},clipRect:function(a,b,
c,d){var e=vc+wd++,f=this.createElement("clipPath").attr({id:e}).add(this.defs);a=this.rect(a,b,c,d,0).add(f);a.id=e;a.clipPath=f;return a},color:function(a,b,c){var d,e=/^rgba/;if(a&&a.linearGradient){var f=this;b=a.linearGradient;c=vc+wd++;var g,h,i;g=f.createElement("linearGradient").attr({id:c,gradientUnits:"userSpaceOnUse",x1:b[0],y1:b[1],x2:b[2],y2:b[3]}).add(f.defs);f.gradients.push(g);g.stops=[];u(a.stops,function(j){if(e.test(j[1])){d=bc(j[1]);h=d.get("rgb");i=d.get("a")}else{h=j[1];i=1}j=
f.createElement("stop").attr({offset:j[0],"stop-color":h,"stop-opacity":i}).add(g);g.stops.push(j)});return"url("+this.url+"#"+c+")"}else if(e.test(a)){d=bc(a);Ga(b,c+"-opacity",d.get("a"));return d.get("rgb")}else{b.removeAttribute(c+"-opacity");return a}},text:function(a,b,c,d){var e=Xa.chart.style;b=W(A(b,0));c=W(A(c,0));a=this.createElement("text").attr({x:b,y:c,text:a}).css({fontFamily:e.fontFamily,fontSize:e.fontSize});a.x=b;a.y=c;a.useHTML=d;return a}};fd=ed;if(!Lc){Db=yb(Uc,{init:function(a,
b){var c=["<",b,' filled="f" stroked="f"'],d=["position: ",ic,";"];if(b==="shape"||b===Tb)d.push("left:0;top:0;width:10px;height:10px;");if(Mc)d.push("visibility: ",b===Tb?ob:Ab);c.push(' style="',d.join(""),'"/>');if(b){c=b===Tb||b==="span"||b==="img"?c.join(""):a.prepVML(c);this.element=hb(c)}this.renderer=a},add:function(a){var b=this.renderer,c=this.element,d=b.box;d=a?a.element||a:d;a&&a.inverted&&b.invertChild(c,d);Mc&&d.gVis===ob&&Ja(c,{visibility:ob});d.appendChild(c);this.added=true;this.alignOnAdd&&
this.updateTransform();return this},attr:function(a,b){var c,d,e,f=this.element||{},g=f.style,h=f.nodeName,i=this.renderer,j=this.symbolName,m,v,P=this.shadows,T=this;if(Sb(a)&&K(b)){c=a;a={};a[c]=b}if(Sb(a)){c=a;T=c==="strokeWidth"||c==="stroke-width"?this.strokeweight:this[c]}else for(c in a){d=a[c];m=false;if(j&&/^(x|y|r|start|end|width|height|innerR)/.test(c)){if(!v){this.symbolAttr(a);v=true}m=true}else if(c==="d"){d=d||[];this.d=d.join(" ");e=d.length;for(m=[];e--;)m[e]=lc(d[e])?W(d[e]*10)-
5:d[e]==="Z"?"x":d[e];d=m.join(" ")||"x";f.path=d;if(P)for(e=P.length;e--;)P[e].path=d;m=true}else if(c==="zIndex"||c==="visibility"){if(Mc&&c==="visibility"&&h==="DIV"){f.gVis=d;m=f.childNodes;for(e=m.length;e--;)Ja(m[e],{visibility:d});if(d===Ab)d=null}if(d)g[c]=d;m=true}else if(/^(width|height)$/.test(c)){this[c]=d;if(this.updateClipping){this[c]=d;this.updateClipping()}else g[c]=d;m=true}else if(/^(x|y)$/.test(c)){this[c]=d;if(f.tagName==="SPAN")this.updateTransform();else g[{x:"left",y:"top"}[c]]=
d}else if(c==="class")f.className=d;else if(c==="stroke"){d=i.color(d,f,c);c="strokecolor"}else if(c==="stroke-width"||c==="strokeWidth"){f.stroked=d?true:false;c="strokeweight";this[c]=d;if(lc(d))d+=Ua}else if(c==="dashstyle"){(f.getElementsByTagName("stroke")[0]||hb(i.prepVML(["<stroke/>"]),null,null,f))[c]=d||"solid";this.dashstyle=d;m=true}else if(c==="fill")if(h==="SPAN")g.color=d;else{f.filled=d!==jb?true:false;d=i.color(d,f,c);c="fillcolor"}else if(c==="translateX"||c==="translateY"||c==="rotation"||
c==="align"){if(c==="align")c="textAlign";this[c]=d;this.updateTransform();m=true}else if(c==="text"){this.bBox=null;f.innerHTML=d;m=true}if(P&&c==="visibility")for(e=P.length;e--;)P[e].style[c]=d;if(!m)if(Mc)f[c]=d;else Ga(f,c,d)}return T},clip:function(a){var b=this,c=a.members;c.push(b);b.destroyClip=function(){nc(c,b)};return b.css(a.getCSS(b.inverted))},css:function(a){var b=this.element;if(b=a&&b.tagName==="SPAN"&&a.width){delete a.width;this.textWidth=b;this.updateTransform()}this.styles=sa(this.styles,
a);Ja(this.element,a);return this},safeRemoveChild:function(a){a.parentNode&&pc(a)},destroy:function(){this.destroyClip&&this.destroyClip();return Uc.prototype.destroy.apply(this)},empty:function(){for(var a=this.element.childNodes,b=a.length,c;b--;){c=a[b];c.parentNode.removeChild(c)}},getBBox:function(){var a=this.element,b=this.bBox;if(!b){if(a.nodeName==="text")a.style.position=ic;b=this.bBox={x:a.offsetLeft,y:a.offsetTop,width:a.offsetWidth,height:a.offsetHeight}}return b},on:function(a,b){this.element["on"+
a]=function(){var c=db.event;c.target=c.srcElement;b(c)};return this},updateTransform:function(){if(this.added){var a=this,b=a.element,c=a.translateX||0,d=a.translateY||0,e=a.x||0,f=a.y||0,g=a.textAlign||"left",h={left:0,center:0.5,right:1}[g],i=g&&g!=="left";if(c||d)a.css({marginLeft:c,marginTop:d});a.inverted&&u(b.childNodes,function(z){a.renderer.invertChild(z,b)});if(b.tagName==="SPAN"){var j,m;c=a.rotation;var v;j=0;d=1;var P=0,T;v=ja(a.textWidth);var Y=a.xCorr||0,H=a.yCorr||0,U=[c,g,b.innerHTML,
a.textWidth].join(",");if(U!==a.cTT){if(K(c)){j=c*ae;d=rb(j);P=Cb(j);Ja(b,{filter:c?["progid:DXImageTransform.Microsoft.Matrix(M11=",d,", M12=",-P,", M21=",P,", M22=",d,", sizingMethod='auto expand')"].join(""):jb})}j=b.offsetWidth;m=b.offsetHeight;if(j>v){Ja(b,{width:v+Ua,display:"block",whiteSpace:"normal"});j=v}v=W((ja(b.style.fontSize)||12)*1.2);Y=d<0&&-j;H=P<0&&-m;T=d*P<0;Y+=P*v*(T?1-h:h);H-=d*v*(c?T?h:1-h:1);if(i){Y-=j*h*(d<0?-1:1);if(c)H-=m*h*(P<0?-1:1);Ja(b,{textAlign:g})}a.xCorr=Y;a.yCorr=
H}Ja(b,{left:e+Y,top:f+H});a.cTT=U}}else this.alignOnAdd=true},shadow:function(a,b){var c=[],d,e=this.element,f=this.renderer,g,h=e.style,i,j=e.path;if(j&&typeof j.value!=="string")j="x";if(a){for(d=1;d<=3;d++){i=['<shape isShadow="true" strokeweight="',7-2*d,'" filled="false" path="',j,'" coordsize="100,100" style="',e.style.cssText,'" />'];g=hb(f.prepVML(i),null,{left:ja(h.left)+1,top:ja(h.top)+1});i=['<stroke color="black" opacity="',0.05*d,'"/>'];hb(f.prepVML(i),null,null,g);b?b.element.appendChild(g):
e.parentNode.insertBefore(g,e);c.push(g)}this.shadows=c}return this}});ma=function(){this.init.apply(this,arguments)};ma.prototype=Ca(ed.prototype,{Element:Db,isIE8:yc.indexOf("MSIE 8.0")>-1,init:function(a,b,c){var d;this.alignedObjects=[];d=this.createElement(Tb);a.appendChild(d.element);this.box=d.element;this.boxWrapper=d;this.setSize(b,c,false);if(!ua.namespaces.hcv){ua.namespaces.add("hcv","urn:schemas-microsoft-com:vml");ua.createStyleSheet().cssText="hcv\\:fill, hcv\\:path, hcv\\:shape, hcv\\:stroke{ behavior:url(#default#VML); display: inline-block; } "}},
clipRect:function(a,b,c,d){var e=this.createElement();return sa(e,{members:[],left:a,top:b,width:c,height:d,getCSS:function(f){var g=this.top,h=this.left,i=h+this.width,j=g+this.height;g={clip:"rect("+W(f?h:g)+"px,"+W(f?j:i)+"px,"+W(f?i:j)+"px,"+W(f?g:h)+"px)"};!f&&Mc&&sa(g,{width:i+Ua,height:j+Ua});return g},updateClipping:function(){u(e.members,function(f){f.css(e.getCSS(f.inverted))})}})},color:function(a,b,c){var d,e=/^rgba/;if(a&&a.linearGradient){var f,g,h=a.linearGradient,i,j,m,v;u(a.stops,
function(P,T){if(e.test(P[1])){d=bc(P[1]);f=d.get("rgb");g=d.get("a")}else{f=P[1];g=1}if(T){m=f;v=g}else{i=f;j=g}});a=90-Fa.atan((h[3]-h[1])/(h[2]-h[0]))*180/kc;a=["<",c,' colors="0% ',i,",100% ",m,'" angle="',a,'" opacity="',v,'" o:opacity2="',j,'" type="gradient" focus="100%" />'];hb(this.prepVML(a),null,null,b)}else if(e.test(a)&&b.tagName!=="IMG"){d=bc(a);a=["<",c,' opacity="',d.get("a"),'"/>'];hb(this.prepVML(a),null,null,b);return d.get("rgb")}else{b=b.getElementsByTagName(c);if(b.length)b[0].opacity=
1;return a}},prepVML:function(a){var b=this.isIE8;a=a.join("");if(b){a=a.replace("/>",' xmlns="urn:schemas-microsoft-com:vml" />');a=a.indexOf('style="')===-1?a.replace("/>",' style="display:inline-block;behavior:url(#default#VML);" />'):a.replace('style="','style="display:inline-block;behavior:url(#default#VML);')}else a=a.replace("<","<hcv:");return a},text:function(a,b,c){var d=Xa.chart.style;return this.createElement("span").attr({text:a,x:W(b),y:W(c)}).css({whiteSpace:"nowrap",fontFamily:d.fontFamily,
fontSize:d.fontSize})},path:function(a){return this.createElement("shape").attr({coordsize:"100 100",d:a})},circle:function(a,b,c){return this.symbol("circle").attr({x:a,y:b,r:c})},g:function(a){var b;if(a)b={className:vc+a,"class":vc+a};return this.createElement(Tb).attr(b)},image:function(a,b,c,d,e){var f=this.createElement("img").attr({src:a});arguments.length>1&&f.css({left:b,top:c,width:d,height:e});return f},rect:function(a,b,c,d,e,f){if(Nb(a)){b=a.y;c=a.width;d=a.height;e=a.r;f=a.strokeWidth;
a=a.x}var g=this.symbol("rect");g.r=e;return g.attr(g.crisp(f,a,b,Ia(c,0),Ia(d,0)))},invertChild:function(a,b){var c=b.style;Ja(a,{flip:"x",left:ja(c.width)-10,top:ja(c.height)-10,rotation:-90})},symbols:{arc:function(a,b,c,d){var e=d.start,f=d.end,g=rb(e),h=Cb(e),i=rb(f),j=Cb(f);d=d.innerR;var m=0.07/c,v=d&&0.1/d||0;if(f-e===0)return["x"];else if(2*kc-f+e<m)i=-m;else if(f-e<v)i=rb(e+v);return["wa",a-c,b-c,a+c,b+c,a+c*g,b+c*h,a+c*i,b+c*j,"at",a-d,b-d,a+d,b+d,a+d*i,b+d*j,a+d*g,b+d*h,"x","e"]},circle:function(a,
b,c){return["wa",a-c,b-c,a+c,b+c,a+c,b,a+c,b,"e"]},rect:function(a,b,c,d){if(!K(d))return[];var e=d.width;d=d.height;var f=a+e,g=b+d;c=tb(c,e,d);return[Za,a+c,b,Ka,f-c,b,"wa",f-2*c,b,f,b+2*c,f-c,b,f,b+c,Ka,f,g-c,"wa",f-2*c,g-2*c,f,g,f,g-c,f-c,g,Ka,a+c,g,"wa",a,g-2*c,a+2*c,g,a+c,g,a,g-c,Ka,a,b+c,"wa",a,b,a+2*c,b+2*c,a,b+c,a+c,b,"x","e"]}}});fd=ma}Nd.prototype.callbacks=[];var Oc=function(){};Oc.prototype={init:function(a,b){var c=a.chart.counters,d;this.series=a;this.applyOptions(b);this.pointAttr=
{};if(a.options.colorByPoint){d=a.chart.options.colors;if(!this.options)this.options={};this.color=this.options.color=this.color||d[c.color++];c.wrapColor(d.length)}a.chart.pointCount++;return this},applyOptions:function(a){var b=this.series;this.config=a;if(lc(a)||a===null)this.y=a;else if(Nb(a)&&!lc(a.length)){sa(this,a);this.options=a}else if(Sb(a[0])){this.name=a[0];this.y=a[1]}else if(lc(a[0])){this.x=a[0];this.y=a[1]}if(this.x===Wa)this.x=b.autoIncrement()},destroy:function(){var a=this,b=a.series,
c=b.chart.hoverPoints,d;b.chart.pointCount--;if(c){a.setState();nc(c,a)}a===b.chart.hoverPoint&&a.onMouseOut();pb(a);u(["graphic","tracker","group","dataLabel","connector","shadowGroup"],function(e){a[e]&&a[e].destroy()});a.legendItem&&a.series.chart.legend.destroyItem(a);for(d in a)a[d]=null},getLabelConfig:function(){return{x:this.category,y:this.y,series:this.series,point:this,percentage:this.percentage,total:this.total||this.stackTotal}},select:function(a,b){var c=this,d=c.series.chart;a=A(a,
!c.selected);c.firePointEvent(a?"select":"unselect",{accumulate:b},function(){c.selected=a;c.setState(a&&"select");b||u(d.getSelectedPoints(),function(e){if(e.selected&&e!==c){e.selected=false;e.setState(ib);e.firePointEvent("unselect")}})})},onMouseOver:function(){var a=this.series.chart,b=a.tooltip,c=a.hoverPoint;c&&c!==this&&c.onMouseOut();this.firePointEvent("mouseOver");b&&!b.shared&&b.refresh(this);this.setState(Bb);a.hoverPoint=this},onMouseOut:function(){this.firePointEvent("mouseOut");this.setState();
this.series.chart.hoverPoint=null},tooltipFormatter:function(a){var b=this.series;return['<span style="color:'+b.color+'">',this.name||b.name,"</span>: ",!a?"<b>x = "+(this.name||this.x)+",</b> ":"","<b>",!a?"y = ":"",this.y,"</b>"].join("")},update:function(a,b,c){var d=this,e=d.series,f=d.graphic,g=e.chart;b=A(b,true);d.firePointEvent("update",{options:a},function(){d.applyOptions(a);if(Nb(a)){e.getAttribs();f&&f.attr(d.pointAttr[e.state])}e.isDirty=true;b&&g.redraw(c)})},remove:function(a,b){var c=
this,d=c.series,e=d.chart,f=d.data;oc(b,e);a=A(a,true);c.firePointEvent("remove",null,function(){nc(f,c);c.destroy();d.isDirty=true;a&&e.redraw()})},firePointEvent:function(a,b,c){var d=this,e=this.series.options;if(e.point.events[a]||d.options&&d.options.events&&d.options.events[a])this.importEvents();if(a==="click"&&e.allowPointSelect)c=function(f){d.select(null,f.ctrlKey||f.metaKey||f.shiftKey)};Pa(this,a,b,c)},importEvents:function(){if(!this.hasImportedEvents){var a=Ca(this.series.options.point,
this.options).events,b;this.events=a;for(b in a)Qa(this,b,a[b]);this.hasImportedEvents=true}},setState:function(a){var b=this.series,c=b.options.states,d=xb[b.type].marker&&b.options.marker,e=d&&!d.enabled,f=(d=d&&d.states[a])&&d.enabled===false,g=b.stateMarkerGraphic,h=b.chart,i=this.pointAttr;a=a||ib;if(!(a===this.state||this.selected&&a!=="select"||c[a]&&c[a].enabled===false||a&&(f||e&&!d.enabled))){if(this.graphic)this.graphic.attr(i[a]);else{if(a){if(!g)b.stateMarkerGraphic=g=h.renderer.circle(0,
0,i[a].r).attr(i[a]).add(b.group);g.translate(this.plotX,this.plotY)}if(g)g[a?"show":"hide"]()}this.state=a}}};var sb=function(){};sb.prototype={isCartesian:true,type:"line",pointClass:Oc,pointAttrToOptions:{stroke:"lineColor","stroke-width":"lineWidth",fill:"fillColor",r:"radius"},init:function(a,b){var c,d;d=a.series.length;this.chart=a;b=this.setOptions(b);sa(this,{index:d,options:b,name:b.name||"Series "+(d+1),state:ib,pointAttr:{},visible:b.visible!==false,selected:b.selected===true});d=b.events;
for(c in d)Qa(this,c,d[c]);if(d&&d.click||b.point&&b.point.events&&b.point.events.click||b.allowPointSelect)a.runTrackerClick=true;this.getColor();this.getSymbol();this.setData(b.data,false)},autoIncrement:function(){var a=this.options,b=this.xIncrement;b=A(b,a.pointStart,0);this.pointInterval=A(this.pointInterval,a.pointInterval,1);this.xIncrement=b+this.pointInterval;return b},cleanData:function(){var a=this.chart,b=this.data,c,d,e=a.smallestInterval,f,g;Hd(b,function(h,i){return h.x-i.x});if(this.options.connectNulls)for(g=
b.length-1;g>=0;g--)b[g].y===null&&b[g-1]&&b[g+1]&&b.splice(g,1);for(g=b.length-1;g>=0;g--)if(b[g-1]){f=b[g].x-b[g-1].x;if(f>0&&(d===Wa||f<d)){d=f;c=g}}if(e===Wa||d<e)a.smallestInterval=d;this.closestPoints=c},getSegments:function(){var a=-1,b=[],c=this.data;u(c,function(d,e){if(d.y===null){e>a+1&&b.push(c.slice(a+1,e));a=e}else e===c.length-1&&b.push(c.slice(a+1,e+1))});this.segments=b},setOptions:function(a){var b=this.chart.options.plotOptions;return Ca(b[this.type],b.series,a)},getColor:function(){var a=
this.chart.options.colors,b=this.chart.counters;this.color=this.options.color||a[b.color++]||"#0000ff";b.wrapColor(a.length)},getSymbol:function(){var a=this.chart.options.symbols,b=this.chart.counters;this.symbol=this.options.marker.symbol||a[b.symbol++];b.wrapSymbol(a.length)},addPoint:function(a,b,c,d){var e=this.data,f=this.graph,g=this.area,h=this.chart;a=(new this.pointClass).init(this,a);oc(d,h);if(f&&c)f.shift=c;if(g){g.shift=c;g.isArea=true}b=A(b,true);e.push(a);c&&e[0].remove(false);this.getAttribs();
this.isDirty=true;b&&h.redraw()},setData:function(a,b){var c=this,d=c.data,e=c.initialColor,f=c.chart,g=d&&d.length||0;c.xIncrement=null;if(K(e))f.counters.color=e;for(a=tc(zc(a||[]),function(h){return(new c.pointClass).init(c,h)});g--;)d[g].destroy();c.data=a;c.cleanData();c.getSegments();c.getAttribs();c.isDirty=true;f.isDirtyBox=true;A(b,true)&&f.redraw(false)},remove:function(a,b){var c=this,d=c.chart;a=A(a,true);if(!c.isRemoving){c.isRemoving=true;Pa(c,"remove",null,function(){c.destroy();d.isDirtyLegend=
d.isDirtyBox=true;a&&d.redraw(b)})}c.isRemoving=false},translate:function(){for(var a=this.chart,b=this.options.stacking,c=this.xAxis.categories,d=this.yAxis,e=this.data,f=e.length;f--;){var g=e[f],h=g.x,i=g.y,j=g.low,m=d.stacks[(i<0?"-":"")+this.stackKey];g.plotX=this.xAxis.translate(h);if(b&&this.visible&&m&&m[h]){j=m[h];h=j.total;j.cum=j=j.cum-i;i=j+i;if(b==="percent"){j=h?j*100/h:0;i=h?i*100/h:0}g.percentage=h?g.y*100/h:0;g.stackTotal=h}if(K(j))g.yBottom=d.translate(j,0,1,0,1);if(i!==null)g.plotY=
d.translate(i,0,1,0,1);g.clientX=a.inverted?a.plotHeight-g.plotX:g.plotX;g.category=c&&c[g.x]!==Wa?c[g.x]:g.x}},setTooltipPoints:function(a){var b=this.chart,c=b.inverted,d=[],e=W((c?b.plotTop:b.plotLeft)+b.plotSizeX),f,g,h=[];if(a)this.tooltipPoints=null;u(this.segments,function(i){d=d.concat(i)});if(this.xAxis&&this.xAxis.reversed)d=d.reverse();u(d,function(i,j){f=d[j-1]?d[j-1]._high+1:0;for(g=i._high=d[j+1]?lb((i.plotX+(d[j+1]?d[j+1].plotX:e))/2):e;f<=g;)h[c?e-f++:f++]=i});this.tooltipPoints=h},
onMouseOver:function(){var a=this.chart,b=a.hoverSeries;if(!(!Kb&&a.mouseIsDown)){b&&b!==this&&b.onMouseOut();this.options.events.mouseOver&&Pa(this,"mouseOver");this.tracker&&this.tracker.toFront();this.setState(Bb);a.hoverSeries=this}},onMouseOut:function(){var a=this.options,b=this.chart,c=b.tooltip,d=b.hoverPoint;d&&d.onMouseOut();this&&a.events.mouseOut&&Pa(this,"mouseOut");c&&!a.stickyTracking&&c.hide();this.setState();b.hoverSeries=null},animate:function(a){var b=this.chart,c=this.clipRect,
d=this.options.animation;if(d&&!Nb(d))d={};if(a){if(!c.isAnimating){c.attr("width",0);c.isAnimating=true}}else{c.animate({width:b.plotSizeX},d);this.animate=null}},drawPoints:function(){var a,b=this.data,c=this.chart,d,e,f,g,h,i;if(this.options.marker.enabled)for(f=b.length;f--;){g=b[f];d=g.plotX;e=g.plotY;i=g.graphic;if(e!==Wa&&!isNaN(e)){a=g.pointAttr[g.selected?"select":ib];h=a.r;if(i)i.animate({x:d,y:e,r:h});else g.graphic=c.renderer.symbol(A(g.marker&&g.marker.symbol,this.symbol),d,e,h).attr(a).add(this.group)}}},
convertAttribs:function(a,b,c,d){var e=this.pointAttrToOptions,f,g,h={};a=a||{};b=b||{};c=c||{};d=d||{};for(f in e){g=e[f];h[f]=A(a[g],b[f],c[f],d[f])}return h},getAttribs:function(){var a=this,b=xb[a.type].marker?a.options.marker:a.options,c=b.states,d=c[Bb],e,f=a.color,g={stroke:f,fill:f},h=a.data,i=[],j,m=a.pointAttrToOptions,v;if(a.options.marker){d.radius=d.radius||b.radius+2;d.lineWidth=d.lineWidth||b.lineWidth+1}else d.color=d.color||bc(d.color||f).brighten(d.brightness).get();i[ib]=a.convertAttribs(b,
g);u([Bb,"select"],function(P){i[P]=a.convertAttribs(c[P],i[ib])});a.pointAttr=i;for(f=h.length;f--;){g=h[f];if((b=g.options&&g.options.marker||g.options)&&b.enabled===false)b.radius=0;e=false;if(g.options)for(v in m)if(K(b[m[v]]))e=true;if(e){j=[];c=b.states||{};e=c[Bb]=c[Bb]||{};if(!a.options.marker)e.color=bc(e.color||g.options.color).brighten(e.brightness||d.brightness).get();j[ib]=a.convertAttribs(b,i[ib]);j[Bb]=a.convertAttribs(c[Bb],i[Bb],j[ib]);j.select=a.convertAttribs(c.select,i.select,
j[ib])}else j=i;g.pointAttr=j}},destroy:function(){var a=this,b=a.chart,c=a.clipRect,d=/\/5[0-9\.]+ (Safari|Mobile)\//.test(yc),e,f;Pa(a,"destroy");pb(a);a.legendItem&&a.chart.legend.destroyItem(a);u(a.data,function(g){g.destroy()});if(c&&c!==b.clipRect)a.clipRect=c.destroy();u(["area","graph","dataLabelsGroup","group","tracker"],function(g){if(a[g]){e=d&&g==="group"?"hide":"destroy";a[g][e]()}});if(b.hoverSeries===a)b.hoverSeries=null;nc(b.series,a);for(f in a)delete a[f]},drawDataLabels:function(){if(this.options.dataLabels.enabled){var a,
b,c=this.data,d=this.options,e=d.dataLabels,f,g=this.dataLabelsGroup,h=this.chart,i=h.renderer,j=h.inverted,m=this.type,v;v=d.stacking;var P=m==="column"||m==="bar",T=e.verticalAlign===null,Y=e.y===null;if(P)if(v){if(T)e=Ca(e,{verticalAlign:"middle"});if(Y)e=Ca(e,{y:{top:14,middle:4,bottom:-6}[e.verticalAlign]})}else if(T)e=Ca(e,{verticalAlign:"top"});if(g)g.translate(h.plotLeft,h.plotTop);else g=this.dataLabelsGroup=i.g("data-labels").attr({visibility:this.visible?Ab:ob,zIndex:6}).translate(h.plotLeft,
h.plotTop).add();v=e.color;if(v==="auto")v=null;e.style.color=A(v,this.color,"black");u(c,function(H){var U=H.barX,z=U&&U+H.barW/2||H.plotX||-999,M=A(H.plotY,-999),y=H.dataLabel,C=e.align,Z=Y?H.y>=0?-6:12:e.y;f=e.formatter.call(H.getLabelConfig());a=(j?h.plotWidth-M:z)+e.x;b=(j?h.plotHeight-z:M)+Z;if(m==="column")a+={left:-1,right:1}[C]*H.barW/2||0;if(j&&H.y<0){C="right";a-=10}if(y){if(j&&!e.y)b=b+ja(y.styles.lineHeight)*0.9-y.getBBox().height/2;y.attr({text:f}).animate({x:a,y:b})}else if(K(f)){y=
H.dataLabel=i.text(f,a,b).attr({align:C,rotation:e.rotation,zIndex:1}).css(e.style).add(g);j&&!e.y&&y.attr({y:b+ja(y.styles.lineHeight)*0.9-y.getBBox().height/2})}if(P&&d.stacking&&y){z=H.barY;M=H.barW;H=H.barH;y.align(e,null,{x:j?h.plotWidth-z-H:U,y:j?h.plotHeight-U-M:z,width:j?H:M,height:j?M:H})}})}},drawGraph:function(){var a=this,b=a.options,c=a.graph,d=[],e,f=a.area,g=a.group,h=b.lineColor||a.color,i=b.lineWidth,j=b.dashStyle,m,v=a.chart.renderer,P=a.yAxis.getThreshold(b.threshold||0),T=/^area/.test(a.type),
Y=[],H=[];u(a.segments,function(U){m=[];u(U,function(C,Z){if(a.getPointSpline)m.push.apply(m,a.getPointSpline(U,C,Z));else{m.push(Z?Ka:Za);Z&&b.step&&m.push(C.plotX,U[Z-1].plotY);m.push(C.plotX,C.plotY)}});if(U.length>1)d=d.concat(m);else Y.push(U[0]);if(T){var z=[],M,y=m.length;for(M=0;M<y;M++)z.push(m[M]);y===3&&z.push(Ka,m[1],m[2]);if(b.stacking&&a.type!=="areaspline")for(M=U.length-1;M>=0;M--)z.push(U[M].plotX,U[M].yBottom);else z.push(Ka,U[U.length-1].plotX,P,Ka,U[0].plotX,P);H=H.concat(z)}});
a.graphPath=d;a.singlePoints=Y;if(T){e=A(b.fillColor,bc(a.color).setOpacity(b.fillOpacity||0.75).get());if(f)f.animate({d:H});else a.area=a.chart.renderer.path(H).attr({fill:e}).add(g)}if(c){Hc(c);c.animate({d:d})}else if(i){c={stroke:h,"stroke-width":i};if(j)c.dashstyle=j;a.graph=v.path(d).attr(c).add(g).shadow(b.shadow)}},render:function(){var a=this,b=a.chart,c,d,e=a.options,f=e.animation,g=f&&a.animate;f=g?f&&f.duration||500:0;var h=a.clipRect,i=b.renderer;if(!h){h=a.clipRect=!b.hasRendered&&
b.clipRect?b.clipRect:i.clipRect(0,0,b.plotSizeX,b.plotSizeY);if(!b.clipRect)b.clipRect=h}if(!a.group){c=a.group=i.g("series");if(b.inverted){d=function(){c.attr({width:b.plotWidth,height:b.plotHeight}).invert()};d();Qa(b,"resize",d);Qa(a,"destroy",function(){pb(b,"resize",d)})}c.clip(a.clipRect).attr({visibility:a.visible?Ab:ob,zIndex:e.zIndex}).translate(b.plotLeft,b.plotTop).add(b.seriesGroup)}a.drawDataLabels();g&&a.animate(true);a.drawGraph&&a.drawGraph();a.drawPoints();a.options.enableMouseTracking!==
false&&a.drawTracker();g&&a.animate();setTimeout(function(){h.isAnimating=false;if((c=a.group)&&h!==b.clipRect&&h.renderer){c.clip(a.clipRect=b.clipRect);h.destroy()}},f);a.isDirty=false},redraw:function(){var a=this.chart,b=this.group;if(b){a.inverted&&b.attr({width:a.plotWidth,height:a.plotHeight});b.animate({translateX:a.plotLeft,translateY:a.plotTop})}this.translate();this.setTooltipPoints(true);this.render()},setState:function(a){var b=this.options,c=this.graph,d=b.states;b=b.lineWidth;a=a||
ib;if(this.state!==a){this.state=a;if(!(d[a]&&d[a].enabled===false)){if(a)b=d[a].lineWidth||b+1;if(c&&!c.dashstyle)c.attr({"stroke-width":b},a?0:500)}}},setVisible:function(a,b){var c=this.chart,d=this.legendItem,e=this.group,f=this.tracker,g=this.dataLabelsGroup,h,i=this.data,j=c.options.chart.ignoreHiddenSeries;h=this.visible;h=(this.visible=a=a===Wa?!h:a)?"show":"hide";e&&e[h]();if(f)f[h]();else for(e=i.length;e--;){f=i[e];f.tracker&&f.tracker[h]()}g&&g[h]();d&&c.legend.colorizeItem(this,a);this.isDirty=
true;this.options.stacking&&u(c.series,function(m){if(m.options.stacking&&m.visible)m.isDirty=true});if(j)c.isDirtyBox=true;b!==false&&c.redraw();Pa(this,h)},show:function(){this.setVisible(true)},hide:function(){this.setVisible(false)},select:function(a){this.selected=a=a===Wa?!this.selected:a;if(this.checkbox)this.checkbox.checked=a;Pa(this,a?"select":"unselect")},drawTracker:function(){var a=this,b=a.options,c=[].concat(a.graphPath),d=c.length,e=a.chart,f=e.options.tooltip.snap,g=a.tracker,h=b.cursor;
h=h&&{cursor:h};var i=a.singlePoints,j;if(d)for(j=d+1;j--;){c[j]===Za&&c.splice(j+1,0,c[j+1]-f,c[j+2],Ka);if(j&&c[j]===Za||j===d)c.splice(j,0,Ka,c[j-2]+f,c[j-1])}for(j=0;j<i.length;j++){d=i[j];c.push(Za,d.plotX-f,d.plotY,Ka,d.plotX+f,d.plotY)}if(g)g.attr({d:c});else a.tracker=e.renderer.path(c).attr({isTracker:true,stroke:ce,fill:jb,"stroke-width":b.lineWidth+2*f,visibility:a.visible?Ab:ob,zIndex:b.zIndex||1}).on(Kb?"touchstart":"mouseover",function(){e.hoverSeries!==a&&a.onMouseOver()}).on("mouseout",
function(){b.stickyTracking||a.onMouseOut()}).css(h).add(e.trackerGroup)}};ma=yb(sb);wb.line=ma;ma=yb(sb,{type:"area"});wb.area=ma;ma=yb(sb,{type:"spline",getPointSpline:function(a,b,c){var d=b.plotX,e=b.plotY,f=a[c-1],g=a[c+1],h,i,j,m;if(c&&c<a.length-1){a=f.plotY;j=g.plotX;g=g.plotY;var v;h=(1.5*d+f.plotX)/2.5;i=(1.5*e+a)/2.5;j=(1.5*d+j)/2.5;m=(1.5*e+g)/2.5;v=(m-i)*(j-d)/(j-h)+e-m;i+=v;m+=v;if(i>a&&i>e){i=Ia(a,e);m=2*e-i}else if(i<a&&i<e){i=tb(a,e);m=2*e-i}if(m>g&&m>e){m=Ia(g,e);i=2*e-m}else if(m<
g&&m<e){m=tb(g,e);i=2*e-m}b.rightContX=j;b.rightContY=m}if(c){b=["C",f.rightContX||f.plotX,f.rightContY||f.plotY,h||d,i||e,d,e];f.rightContX=f.rightContY=null}else b=[Za,d,e];return b}});wb.spline=ma;ma=yb(ma,{type:"areaspline"});wb.areaspline=ma;var hd=yb(sb,{type:"column",pointAttrToOptions:{stroke:"borderColor","stroke-width":"borderWidth",fill:"color",r:"borderRadius"},init:function(){sb.prototype.init.apply(this,arguments);var a=this,b=a.chart;b.hasColumn=true;b.hasRendered&&u(b.series,function(c){if(c.type===
a.type)c.isDirty=true})},translate:function(){var a=this,b=a.chart,c=a.options,d=c.stacking,e=c.borderWidth,f=0,g=a.xAxis.reversed,h=a.xAxis.categories,i={},j,m;sb.prototype.translate.apply(a);u(b.series,function(C){if(C.type===a.type&&C.visible){if(C.options.stacking){j=C.stackKey;if(i[j]===Wa)i[j]=f++;m=i[j]}else m=f++;C.columnIndex=m}});var v=a.data,P=a.closestPoints;h=bb(v[1]?v[P].plotX-v[P-1].plotX:b.plotSizeX/(h&&h.length||1));P=h*c.groupPadding;var T=(h-2*P)/f,Y=c.pointWidth,H=K(Y)?(T-Y)/2:
T*c.pointPadding,U=Ia(A(Y,T-2*H),1),z=H+(P+((g?f-a.columnIndex:a.columnIndex)||0)*T-h/2)*(g?-1:1),M=a.yAxis.getThreshold(c.threshold||0),y=A(c.minPointLength,5);u(v,function(C){var Z=C.plotY,Sa=C.yBottom||M,Na=C.plotX+z,Ea=md(tb(Z,Sa)),gb=md(Ia(Z,Sa)-Ea),Lb=a.yAxis.stacks[(C.y<0?"-":"")+a.stackKey],Rb;d&&a.visible&&Lb&&Lb[C.x]&&Lb[C.x].setOffset(z,U);if(bb(gb)<y){if(y){gb=y;Ea=bb(Ea-M)>y?Sa-y:M-(Z<=M?y:0)}Rb=Ea-3}sa(C,{barX:Na,barY:Ea,barW:U,barH:gb});C.shapeType="rect";Z=sa(b.renderer.Element.prototype.crisp.apply({},
[e,Na,Ea,U,gb]),{r:c.borderRadius});if(e%2){Z.y-=1;Z.height+=1}C.shapeArgs=Z;C.trackerArgs=K(Rb)&&Ca(C.shapeArgs,{height:Ia(6,gb+3),y:Rb})})},getSymbol:function(){},drawGraph:function(){},drawPoints:function(){var a=this,b=a.options,c=a.chart.renderer,d,e;u(a.data,function(f){var g=f.plotY;if(g!==Wa&&!isNaN(g)&&f.y!==null){d=f.graphic;e=f.shapeArgs;if(d){Hc(d);d.animate(e)}else f.graphic=c[f.shapeType](e).attr(f.pointAttr[f.selected?"select":ib]).add(a.group).shadow(b.shadow)}})},drawTracker:function(){var a=
this,b=a.chart,c=b.renderer,d,e,f=+new Date,g=a.options,h=g.cursor,i=h&&{cursor:h},j;u(a.data,function(m){e=m.tracker;d=m.trackerArgs||m.shapeArgs;delete d.strokeWidth;if(m.y!==null)if(e)e.attr(d);else m.tracker=c[m.shapeType](d).attr({isTracker:f,fill:ce,visibility:a.visible?Ab:ob,zIndex:g.zIndex||1}).on(Kb?"touchstart":"mouseover",function(v){j=v.relatedTarget||v.fromElement;b.hoverSeries!==a&&Ga(j,"isTracker")!==f&&a.onMouseOver();m.onMouseOver()}).on("mouseout",function(v){if(!g.stickyTracking){j=
v.relatedTarget||v.toElement;Ga(j,"isTracker")!==f&&a.onMouseOut()}}).css(i).add(m.group||b.trackerGroup)})},animate:function(a){var b=this,c=b.data;if(!a){u(c,function(d){var e=d.graphic;d=d.shapeArgs;if(e){e.attr({height:0,y:b.yAxis.translate(0,0,1)});e.animate({height:d.height,y:d.y},b.options.animation)}});b.animate=null}},remove:function(){var a=this,b=a.chart;b.hasRendered&&u(b.series,function(c){if(c.type===a.type)c.isDirty=true});sb.prototype.remove.apply(a,arguments)}});wb.column=hd;ma=yb(hd,
{type:"bar",init:function(a){a.inverted=this.inverted=true;hd.prototype.init.apply(this,arguments)}});wb.bar=ma;ma=yb(sb,{type:"scatter",translate:function(){var a=this;sb.prototype.translate.apply(a);u(a.data,function(b){b.shapeType="circle";b.shapeArgs={x:b.plotX,y:b.plotY,r:a.chart.options.tooltip.snap}})},drawTracker:function(){var a=this,b=a.options.cursor,c=b&&{cursor:b},d;u(a.data,function(e){(d=e.graphic)&&d.attr({isTracker:true}).on("mouseover",function(){a.onMouseOver();e.onMouseOver()}).on("mouseout",
function(){a.options.stickyTracking||a.onMouseOut()}).css(c)})},cleanData:function(){}});wb.scatter=ma;ma=yb(Oc,{init:function(){Oc.prototype.init.apply(this,arguments);var a=this,b;sa(a,{visible:a.visible!==false,name:A(a.name,"Slice")});b=function(){a.slice()};Qa(a,"select",b);Qa(a,"unselect",b);return a},setVisible:function(a){var b=this.series.chart,c=this.tracker,d=this.dataLabel,e=this.connector,f=this.shadowGroup,g;g=(this.visible=a=a===Wa?!this.visible:a)?"show":"hide";this.group[g]();c&&
c[g]();d&&d[g]();e&&e[g]();f&&f[g]();this.legendItem&&b.legend.colorizeItem(this,a)},slice:function(a,b,c){var d=this.series.chart,e=this.slicedTranslation;oc(c,d);A(b,true);a=this.sliced=K(a)?a:!this.sliced;a={translateX:a?e[0]:d.plotLeft,translateY:a?e[1]:d.plotTop};this.group.animate(a);this.shadowGroup&&this.shadowGroup.animate(a)}});ma=yb(sb,{type:"pie",isCartesian:false,pointClass:ma,pointAttrToOptions:{stroke:"borderColor","stroke-width":"borderWidth",fill:"color"},getColor:function(){this.initialColor=
this.chart.counters.color},animate:function(){var a=this;u(a.data,function(b){var c=b.graphic;b=b.shapeArgs;var d=-kc/2;if(c){c.attr({r:0,start:d,end:d});c.animate({r:b.r,start:b.start,end:b.end},a.options.animation)}});a.animate=null},translate:function(){var a=0,b=-0.25,c=this.options,d=c.slicedOffset,e=d+c.borderWidth,f=c.center.concat([c.size,c.innerSize||0]),g=this.chart,h=g.plotWidth,i=g.plotHeight,j,m,v,P=this.data,T=2*kc,Y,H=tb(h,i),U,z,M,y=c.dataLabels.distance;f=tc(f,function(C,Z){return(U=
/%$/.test(C))?[h,i,H,H][Z]*ja(C)/100:C});this.getX=function(C,Z){v=Fa.asin((C-f[1])/(f[2]/2+y));return f[0]+(Z?-1:1)*rb(v)*(f[2]/2+y)};this.center=f;u(P,function(C){a+=C.y});u(P,function(C){Y=a?C.y/a:0;j=W(b*T*1E3)/1E3;b+=Y;m=W(b*T*1E3)/1E3;C.shapeType="arc";C.shapeArgs={x:f[0],y:f[1],r:f[2]/2,innerR:f[3]/2,start:j,end:m};v=(m+j)/2;C.slicedTranslation=tc([rb(v)*d+g.plotLeft,Cb(v)*d+g.plotTop],W);z=rb(v)*f[2]/2;M=Cb(v)*f[2]/2;C.tooltipPos=[f[0]+z*0.7,f[1]+M*0.7];C.labelPos=[f[0]+z+rb(v)*y,f[1]+M+Cb(v)*
y,f[0]+z+rb(v)*e,f[1]+M+Cb(v)*e,f[0]+z,f[1]+M,y<0?"center":v<T/4?"left":"right",v];C.percentage=Y*100;C.total=a});this.setTooltipPoints()},render:function(){this.drawPoints();this.options.enableMouseTracking!==false&&this.drawTracker();this.drawDataLabels();this.options.animation&&this.animate&&this.animate();this.isDirty=false},drawPoints:function(){var a=this.chart,b=a.renderer,c,d,e,f=this.options.shadow,g,h;u(this.data,function(i){d=i.graphic;h=i.shapeArgs;e=i.group;g=i.shadowGroup;if(f&&!g)g=
i.shadowGroup=b.g("shadow").attr({zIndex:4}).add();if(!e)e=i.group=b.g("point").attr({zIndex:5}).add();c=i.sliced?i.slicedTranslation:[a.plotLeft,a.plotTop];e.translate(c[0],c[1]);g&&g.translate(c[0],c[1]);if(d)d.animate(h);else i.graphic=b.arc(h).attr(sa(i.pointAttr[ib],{"stroke-linejoin":"round"})).add(i.group).shadow(f,g);i.visible===false&&i.setVisible(false)})},drawDataLabels:function(){var a=this.data,b,c=this.chart,d=this.options.dataLabels,e=A(d.connectorPadding,10),f=A(d.connectorWidth,1),
g,h,i=A(d.softConnector,true),j=d.distance,m=this.center,v=m[2]/2;m=m[1];var P=j>0,T=[[],[]],Y,H,U,z,M=2,y;if(d.enabled){sb.prototype.drawDataLabels.apply(this);u(a,function(gb){if(gb.dataLabel)T[gb.labelPos[7]<kc/2?0:1].push(gb)});T[1].reverse();z=function(gb,Lb){return Lb.y-gb.y};for(a=T[0][0]&&T[0][0].dataLabel&&ja(T[0][0].dataLabel.styles.lineHeight);M--;){var C=[],Z=[],Sa=T[M],Na=Sa.length,Ea;for(y=m-v-j;y<=m+v+j;y+=a)C.push(y);U=C.length;if(Na>U){h=[].concat(Sa);h.sort(z);for(y=Na;y--;)h[y].rank=
y;for(y=Na;y--;)Sa[y].rank>=U&&Sa.splice(y,1);Na=Sa.length}for(y=0;y<Na;y++){b=Sa[y];h=b.labelPos;b=9999;for(H=0;H<U;H++){g=bb(C[H]-h[1]);if(g<b){b=g;Ea=H}}if(Ea<y&&C[y]!==null)Ea=y;else{if(U<Na-y+Ea&&C[y]!==null)Ea=U-Na+y;for(;C[Ea]===null;)Ea++}Z.push({i:Ea,y:C[Ea]});C[Ea]=null}Z.sort(z);for(y=0;y<Na;y++){b=Sa[y];h=b.labelPos;g=b.dataLabel;H=Z.pop();Y=h[1];U=b.visible===false?ob:Ab;Ea=H.i;H=H.y;if(Y>H&&C[Ea+1]!==null||Y<H&&C[Ea-1]!==null)H=Y;Y=this.getX(Ea===0||Ea===C.length-1?Y:H,M);g.attr({visibility:U,
align:h[6]})[g.moved?"animate":"attr"]({x:Y+d.x+({left:e,right:-e}[h[6]]||0),y:H+d.y});g.moved=true;if(P&&f){g=b.connector;h=i?[Za,Y+(h[6]==="left"?5:-5),H,"C",Y,H,2*h[2]-h[4],2*h[3]-h[5],h[2],h[3],Ka,h[4],h[5]]:[Za,Y+(h[6]==="left"?5:-5),H,Ka,h[2],h[3],Ka,h[4],h[5]];if(g){g.animate({d:h});g.attr("visibility",U)}else b.connector=g=this.chart.renderer.path(h).attr({"stroke-width":f,stroke:d.connectorColor||b.color||"#606060",visibility:U,zIndex:3}).translate(c.plotLeft,c.plotTop).add()}}}}},drawTracker:hd.prototype.drawTracker,
getSymbol:function(){}});wb.pie=ma;db.Highcharts={Chart:Nd,dateFormat:Zc,pathAnim:Nc,getOptions:function(){return Xa},hasRtlBug:me,numberFormat:Ed,Point:Oc,Color:bc,Renderer:fd,seriesTypes:wb,setOptions:function(a){Xa=Ca(Xa,a);Id();return Xa},Series:sb,addEvent:Qa,removeEvent:pb,createElement:hb,discardElement:pc,css:Ja,each:u,extend:sa,map:tc,merge:Ca,pick:A,extendClass:yb,product:"Highcharts",version:"2.1.9"}})();
(function(){if (!Date.now) Date.now = function() {
  return +new Date;
};
try {
  document.createElement("div").style.setProperty("opacity", 0, "");
} catch (error) {
  var d3_style_prototype = CSSStyleDeclaration.prototype,
      d3_style_setProperty = d3_style_prototype.setProperty;
  d3_style_prototype.setProperty = function(name, value, priority) {
    d3_style_setProperty.call(this, name, value + "", priority);
  };
}
d3 = {version: "2.7.4"}; // semver
var d3_array = d3_arraySlice; // conversion for NodeLists

function d3_arrayCopy(pseudoarray) {
  var i = -1, n = pseudoarray.length, array = [];
  while (++i < n) array.push(pseudoarray[i]);
  return array;
}

function d3_arraySlice(pseudoarray) {
  return Array.prototype.slice.call(pseudoarray);
}

try {
  d3_array(document.documentElement.childNodes)[0].nodeType;
} catch(e) {
  d3_array = d3_arrayCopy;
}

var d3_arraySubclass = [].__proto__?

// Until ECMAScript supports array subclassing, prototype injection works well.
function(array, prototype) {
  array.__proto__ = prototype;
}:

// And if your browser doesn't support __proto__, we'll use direct extension.
function(array, prototype) {
  for (var property in prototype) array[property] = prototype[property];
};
function d3_this() {
  return this;
}
d3.functor = function(v) {
  return typeof v === "function" ? v : function() { return v; };
};
// Copies a variable number of methods from source to target.
d3.rebind = function(target, source) {
  var i = 1, n = arguments.length, method;
  while (++i < n) target[method = arguments[i]] = d3_rebind(target, source, source[method]);
  return target;
};

// Method is assumed to be a standard D3 getter-setter:
// If passed with no arguments, gets the value.
// If passed with arguments, sets the value and returns the target.
function d3_rebind(target, source, method) {
  return function() {
    var value = method.apply(source, arguments);
    return arguments.length ? target : value;
  };
}
d3.ascending = function(a, b) {
  return a < b ? -1 : a > b ? 1 : a >= b ? 0 : NaN;
};
d3.descending = function(a, b) {
  return b < a ? -1 : b > a ? 1 : b >= a ? 0 : NaN;
};
d3.mean = function(array, f) {
  var n = array.length,
      a,
      m = 0,
      i = -1,
      j = 0;
  if (arguments.length === 1) {
    while (++i < n) if (d3_number(a = array[i])) m += (a - m) / ++j;
  } else {
    while (++i < n) if (d3_number(a = f.call(array, array[i], i))) m += (a - m) / ++j;
  }
  return j ? m : undefined;
};
d3.median = function(array, f) {
  if (arguments.length > 1) array = array.map(f);
  array = array.filter(d3_number);
  return array.length ? d3.quantile(array.sort(d3.ascending), .5) : undefined;
};
d3.min = function(array, f) {
  var i = -1,
      n = array.length,
      a,
      b;
  if (arguments.length === 1) {
    while (++i < n && ((a = array[i]) == null || a != a)) a = undefined;
    while (++i < n) if ((b = array[i]) != null && a > b) a = b;
  } else {
    while (++i < n && ((a = f.call(array, array[i], i)) == null || a != a)) a = undefined;
    while (++i < n) if ((b = f.call(array, array[i], i)) != null && a > b) a = b;
  }
  return a;
};
d3.max = function(array, f) {
  var i = -1,
      n = array.length,
      a,
      b;
  if (arguments.length === 1) {
    while (++i < n && ((a = array[i]) == null || a != a)) a = undefined;
    while (++i < n) if ((b = array[i]) != null && b > a) a = b;
  } else {
    while (++i < n && ((a = f.call(array, array[i], i)) == null || a != a)) a = undefined;
    while (++i < n) if ((b = f.call(array, array[i], i)) != null && b > a) a = b;
  }
  return a;
};
d3.extent = function(array, f) {
  var i = -1,
      n = array.length,
      a,
      b,
      c;
  if (arguments.length === 1) {
    while (++i < n && ((a = c = array[i]) == null || a != a)) a = c = undefined;
    while (++i < n) if ((b = array[i]) != null) {
      if (a > b) a = b;
      if (c < b) c = b;
    }
  } else {
    while (++i < n && ((a = c = f.call(array, array[i], i)) == null || a != a)) a = undefined;
    while (++i < n) if ((b = f.call(array, array[i], i)) != null) {
      if (a > b) a = b;
      if (c < b) c = b;
    }
  }
  return [a, c];
};
d3.random = {
  normal: function(mean, deviation) {
    if (arguments.length < 2) deviation = 1;
    if (arguments.length < 1) mean = 0;
    return function() {
      var x, y, r;
      do {
        x = Math.random() * 2 - 1;
        y = Math.random() * 2 - 1;
        r = x * x + y * y;
      } while (!r || r > 1);
      return mean + deviation * x * Math.sqrt(-2 * Math.log(r) / r);
    };
  }
};
function d3_number(x) {
  return x != null && !isNaN(x);
}
d3.sum = function(array, f) {
  var s = 0,
      n = array.length,
      a,
      i = -1;

  if (arguments.length === 1) {
    while (++i < n) if (!isNaN(a = +array[i])) s += a;
  } else {
    while (++i < n) if (!isNaN(a = +f.call(array, array[i], i))) s += a;
  }

  return s;
};
// R-7 per <http://en.wikipedia.org/wiki/Quantile>
d3.quantile = function(values, p) {
  var H = (values.length - 1) * p + 1,
      h = Math.floor(H),
      v = values[h - 1],
      e = H - h;
  return e ? v + e * (values[h] - v) : v;
};
d3.transpose = function(matrix) {
  return d3.zip.apply(d3, matrix);
};
d3.zip = function() {
  if (!(n = arguments.length)) return [];
  for (var i = -1, m = d3.min(arguments, d3_zipLength), zips = new Array(m); ++i < m;) {
    for (var j = -1, n, zip = zips[i] = new Array(n); ++j < n;) {
      zip[j] = arguments[j][i];
    }
  }
  return zips;
};

function d3_zipLength(d) {
  return d.length;
}
// Locate the insertion point for x in a to maintain sorted order. The
// arguments lo and hi may be used to specify a subset of the array which should
// be considered; by default the entire array is used. If x is already present
// in a, the insertion point will be before (to the left of) any existing
// entries. The return value is suitable for use as the first argument to
// `array.splice` assuming that a is already sorted.
//
// The returned insertion point i partitions the array a into two halves so that
// all v < x for v in a[lo:i] for the left side and all v >= x for v in a[i:hi]
// for the right side.
d3.bisectLeft = function(a, x, lo, hi) {
  if (arguments.length < 3) lo = 0;
  if (arguments.length < 4) hi = a.length;
  while (lo < hi) {
    var mid = (lo + hi) >> 1;
    if (a[mid] < x) lo = mid + 1;
    else hi = mid;
  }
  return lo;
};

// Similar to bisectLeft, but returns an insertion point which comes after (to
// the right of) any existing entries of x in a.
//
// The returned insertion point i partitions the array into two halves so that
// all v <= x for v in a[lo:i] for the left side and all v > x for v in a[i:hi]
// for the right side.
d3.bisect =
d3.bisectRight = function(a, x, lo, hi) {
  if (arguments.length < 3) lo = 0;
  if (arguments.length < 4) hi = a.length;
  while (lo < hi) {
    var mid = (lo + hi) >> 1;
    if (x < a[mid]) hi = mid;
    else lo = mid + 1;
  }
  return lo;
};
d3.first = function(array, f) {
  var i = 0,
      n = array.length,
      a = array[0],
      b;
  if (arguments.length === 1) f = d3.ascending;
  while (++i < n) {
    if (f.call(array, a, b = array[i]) > 0) {
      a = b;
    }
  }
  return a;
};
d3.last = function(array, f) {
  var i = 0,
      n = array.length,
      a = array[0],
      b;
  if (arguments.length === 1) f = d3.ascending;
  while (++i < n) {
    if (f.call(array, a, b = array[i]) <= 0) {
      a = b;
    }
  }
  return a;
};
d3.nest = function() {
  var nest = {},
      keys = [],
      sortKeys = [],
      sortValues,
      rollup;

  function map(array, depth) {
    if (depth >= keys.length) return rollup
        ? rollup.call(nest, array) : (sortValues
        ? array.sort(sortValues)
        : array);

    var i = -1,
        n = array.length,
        key = keys[depth++],
        keyValue,
        object,
        o = {};

    while (++i < n) {
      if ((keyValue = key(object = array[i])) in o) {
        o[keyValue].push(object);
      } else {
        o[keyValue] = [object];
      }
    }

    for (keyValue in o) {
      o[keyValue] = map(o[keyValue], depth);
    }

    return o;
  }

  function entries(map, depth) {
    if (depth >= keys.length) return map;

    var a = [],
        sortKey = sortKeys[depth++],
        key;

    for (key in map) {
      a.push({key: key, values: entries(map[key], depth)});
    }

    if (sortKey) a.sort(function(a, b) {
      return sortKey(a.key, b.key);
    });

    return a;
  }

  nest.map = function(array) {
    return map(array, 0);
  };

  nest.entries = function(array) {
    return entries(map(array, 0), 0);
  };

  nest.key = function(d) {
    keys.push(d);
    return nest;
  };

  // Specifies the order for the most-recently specified key.
  // Note: only applies to entries. Map keys are unordered!
  nest.sortKeys = function(order) {
    sortKeys[keys.length - 1] = order;
    return nest;
  };

  // Specifies the order for leaf values.
  // Applies to both maps and entries array.
  nest.sortValues = function(order) {
    sortValues = order;
    return nest;
  };

  nest.rollup = function(f) {
    rollup = f;
    return nest;
  };

  return nest;
};
d3.keys = function(map) {
  var keys = [];
  for (var key in map) keys.push(key);
  return keys;
};
d3.values = function(map) {
  var values = [];
  for (var key in map) values.push(map[key]);
  return values;
};
d3.entries = function(map) {
  var entries = [];
  for (var key in map) entries.push({key: key, value: map[key]});
  return entries;
};
d3.permute = function(array, indexes) {
  var permutes = [],
      i = -1,
      n = indexes.length;
  while (++i < n) permutes[i] = array[indexes[i]];
  return permutes;
};
d3.merge = function(arrays) {
  return Array.prototype.concat.apply([], arrays);
};
d3.split = function(array, f) {
  var arrays = [],
      values = [],
      value,
      i = -1,
      n = array.length;
  if (arguments.length < 2) f = d3_splitter;
  while (++i < n) {
    if (f.call(values, value = array[i], i)) {
      values = [];
    } else {
      if (!values.length) arrays.push(values);
      values.push(value);
    }
  }
  return arrays;
};

function d3_splitter(d) {
  return d == null;
}
function d3_collapse(s) {
  return s.replace(/(^\s+)|(\s+$)/g, "").replace(/\s+/g, " ");
}
/**
 * @param {number} start
 * @param {number=} stop
 * @param {number=} step
 */
d3.range = function(start, stop, step) {
  if (arguments.length < 3) {
    step = 1;
    if (arguments.length < 2) {
      stop = start;
      start = 0;
    }
  }
  if ((stop - start) / step == Infinity) throw new Error("infinite range");
  var range = [],
       i = -1,
       j;
  if (step < 0) while ((j = start + step * ++i) > stop) range.push(j);
  else while ((j = start + step * ++i) < stop) range.push(j);
  return range;
};
d3.requote = function(s) {
  return s.replace(d3_requote_re, "\\$&");
};

var d3_requote_re = /[\\\^\$\*\+\?\|\[\]\(\)\.\{\}]/g;
d3.round = function(x, n) {
  return n
      ? Math.round(x * (n = Math.pow(10, n))) / n
      : Math.round(x);
};
d3.xhr = function(url, mime, callback) {
  var req = new XMLHttpRequest;
  if (arguments.length < 3) callback = mime, mime = null;
  else if (mime && req.overrideMimeType) req.overrideMimeType(mime);
  req.open("GET", url, true);
  if (mime) req.setRequestHeader("Accept", mime);
  req.onreadystatechange = function() {
    if (req.readyState === 4) callback(req.status < 300 ? req : null);
  };
  req.send(null);
};
d3.text = function(url, mime, callback) {
  function ready(req) {
    callback(req && req.responseText);
  }
  if (arguments.length < 3) {
    callback = mime;
    mime = null;
  }
  d3.xhr(url, mime, ready);
};
d3.json = function(url, callback) {
  d3.text(url, "application/json", function(text) {
    callback(text ? JSON.parse(text) : null);
  });
};
d3.html = function(url, callback) {
  d3.text(url, "text/html", function(text) {
    if (text != null) { // Treat empty string as valid HTML.
      var range = document.createRange();
      range.selectNode(document.body);
      text = range.createContextualFragment(text);
    }
    callback(text);
  });
};
d3.xml = function(url, mime, callback) {
  function ready(req) {
    callback(req && req.responseXML);
  }
  if (arguments.length < 3) {
    callback = mime;
    mime = null;
  }
  d3.xhr(url, mime, ready);
};
var d3_nsPrefix = {
  svg: "http://www.w3.org/2000/svg",
  xhtml: "http://www.w3.org/1999/xhtml",
  xlink: "http://www.w3.org/1999/xlink",
  xml: "http://www.w3.org/XML/1998/namespace",
  xmlns: "http://www.w3.org/2000/xmlns/"
};

d3.ns = {
  prefix: d3_nsPrefix,
  qualify: function(name) {
    var i = name.indexOf(":");
    return i < 0 ? (name in d3_nsPrefix
      ? {space: d3_nsPrefix[name], local: name} : name)
      : {space: d3_nsPrefix[name.substring(0, i)], local: name.substring(i + 1)};
  }
};
d3.dispatch = function() {
  var dispatch = new d3_dispatch(),
      i = -1,
      n = arguments.length;
  while (++i < n) dispatch[arguments[i]] = d3_dispatch_event(dispatch);
  return dispatch;
};

function d3_dispatch() {}

d3_dispatch.prototype.on = function(type, listener) {
  var i = type.indexOf("."),
      name = "";

  // Extract optional namespace, e.g., "click.foo"
  if (i > 0) {
    name = type.substring(i + 1);
    type = type.substring(0, i);
  }

  return arguments.length < 2
      ? this[type].on(name)
      : this[type].on(name, listener);
};

function d3_dispatch_event(dispatch) {
  var listeners = [],
      listenerByName = {};

  function event() {
    var z = listeners, // defensive reference
        i = -1,
        n = z.length,
        l;
    while (++i < n) if (l = z[i].on) l.apply(this, arguments);
    return dispatch;
  }

  event.on = function(name, listener) {
    var l, i;

    // return the current listener, if any
    if (arguments.length < 2) return (l = listenerByName[name]) && l.on;

    // remove the old listener, if any (with copy-on-write)
    if (l = listenerByName[name]) {
      l.on = null;
      listeners = listeners.slice(0, i = listeners.indexOf(l)).concat(listeners.slice(i + 1));
      delete listenerByName[name];
    }

    // add the new listener, if any
    if (listener) {
      listeners.push(listenerByName[name] = {on: listener});
    }

    return dispatch;
  };

  return event;
};
// TODO align
d3.format = function(specifier) {
  var match = d3_format_re.exec(specifier),
      fill = match[1] || " ",
      sign = match[3] || "",
      zfill = match[5],
      width = +match[6],
      comma = match[7],
      precision = match[8],
      type = match[9],
      scale = 1,
      suffix = "",
      integer = false;

  if (precision) precision = +precision.substring(1);

  if (zfill) {
    fill = "0"; // TODO align = "=";
    if (comma) width -= Math.floor((width - 1) / 4);
  }

  switch (type) {
    case "n": comma = true; type = "g"; break;
    case "%": scale = 100; suffix = "%"; type = "f"; break;
    case "p": scale = 100; suffix = "%"; type = "r"; break;
    case "d": integer = true; precision = 0; break;
    case "s": scale = -1; type = "r"; break;
  }

  // If no precision is specified for r, fallback to general notation.
  if (type == "r" && !precision) type = "g";

  type = d3_format_types[type] || d3_format_typeDefault;

  return function(value) {

    // Return the empty string for floats formatted as ints.
    if (integer && (value % 1)) return "";

    // Convert negative to positive, and record the sign prefix.
    var negative = (value < 0) && (value = -value) ? "\u2212" : sign;

    // Apply the scale, computing it from the value's exponent for si format.
    if (scale < 0) {
      var prefix = d3.formatPrefix(value, precision);
      value *= prefix.scale;
      suffix = prefix.symbol;
    } else {
      value *= scale;
    }

    // Convert to the desired precision.
    value = type(value, precision);

    // If the fill character is 0, the sign and group is applied after the fill.
    if (zfill) {
      var length = value.length + negative.length;
      if (length < width) value = new Array(width - length + 1).join(fill) + value;
      if (comma) value = d3_format_group(value);
      value = negative + value;
    }

    // Otherwise (e.g., space-filling), the sign and group is applied before.
    else {
      if (comma) value = d3_format_group(value);
      value = negative + value;
      var length = value.length;
      if (length < width) value = new Array(width - length + 1).join(fill) + value;
    }

    return value + suffix;
  };
};

// [[fill]align][sign][#][0][width][,][.precision][type]
var d3_format_re = /(?:([^{])?([<>=^]))?([+\- ])?(#)?(0)?([0-9]+)?(,)?(\.[0-9]+)?([a-zA-Z%])?/;

var d3_format_types = {
  g: function(x, p) { return x.toPrecision(p); },
  e: function(x, p) { return x.toExponential(p); },
  f: function(x, p) { return x.toFixed(p); },
  r: function(x, p) { return d3.round(x, p = d3_format_precision(x, p)).toFixed(Math.max(0, Math.min(20, p))); }
};

function d3_format_precision(x, p) {
  return p - (x ? 1 + Math.floor(Math.log(x + Math.pow(10, 1 + Math.floor(Math.log(x) / Math.LN10) - p)) / Math.LN10) : 1);
}

function d3_format_typeDefault(x) {
  return x + "";
}

// Apply comma grouping for thousands.
function d3_format_group(value) {
  var i = value.lastIndexOf("."),
      f = i >= 0 ? value.substring(i) : (i = value.length, ""),
      t = [];
  while (i > 0) t.push(value.substring(i -= 3, i + 3));
  return t.reverse().join(",") + f;
}
var d3_formatPrefixes = ["y","z","a","f","p","n","μ","m","","k","M","G","T","P","E","Z","Y"].map(d3_formatPrefix);

d3.formatPrefix = function(value, precision) {
  var i = 0;
  if (value) {
    if (value < 0) value *= -1;
    if (precision) value = d3.round(value, d3_format_precision(value, precision));
    i = 1 + Math.floor(1e-12 + Math.log(value) / Math.LN10);
    i = Math.max(-24, Math.min(24, Math.floor((i <= 0 ? i + 1 : i - 1) / 3) * 3));
  }
  return d3_formatPrefixes[8 + i / 3];
};

function d3_formatPrefix(d, i) {
  return {
    scale: Math.pow(10, (8 - i) * 3),
    symbol: d
  };
}

/*
 * TERMS OF USE - EASING EQUATIONS
 *
 * Open source under the BSD License.
 *
 * Copyright 2001 Robert Penner
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * - Neither the name of the author nor the names of contributors may be used to
 *   endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

var d3_ease_quad = d3_ease_poly(2),
    d3_ease_cubic = d3_ease_poly(3);

var d3_ease = {
  linear: function() { return d3_ease_linear; },
  poly: d3_ease_poly,
  quad: function() { return d3_ease_quad; },
  cubic: function() { return d3_ease_cubic; },
  sin: function() { return d3_ease_sin; },
  exp: function() { return d3_ease_exp; },
  circle: function() { return d3_ease_circle; },
  elastic: d3_ease_elastic,
  back: d3_ease_back,
  bounce: function() { return d3_ease_bounce; }
};

var d3_ease_mode = {
  "in": function(f) { return f; },
  "out": d3_ease_reverse,
  "in-out": d3_ease_reflect,
  "out-in": function(f) { return d3_ease_reflect(d3_ease_reverse(f)); }
};

d3.ease = function(name) {
  var i = name.indexOf("-"),
      t = i >= 0 ? name.substring(0, i) : name,
      m = i >= 0 ? name.substring(i + 1) : "in";
  return d3_ease_clamp(d3_ease_mode[m](d3_ease[t].apply(null, Array.prototype.slice.call(arguments, 1))));
};

function d3_ease_clamp(f) {
  return function(t) {
    return t <= 0 ? 0 : t >= 1 ? 1 : f(t);
  };
}

function d3_ease_reverse(f) {
  return function(t) {
    return 1 - f(1 - t);
  };
}

function d3_ease_reflect(f) {
  return function(t) {
    return .5 * (t < .5 ? f(2 * t) : (2 - f(2 - 2 * t)));
  };
}

function d3_ease_linear(t) {
  return t;
}

function d3_ease_poly(e) {
  return function(t) {
    return Math.pow(t, e);
  }
}

function d3_ease_sin(t) {
  return 1 - Math.cos(t * Math.PI / 2);
}

function d3_ease_exp(t) {
  return Math.pow(2, 10 * (t - 1));
}

function d3_ease_circle(t) {
  return 1 - Math.sqrt(1 - t * t);
}

function d3_ease_elastic(a, p) {
  var s;
  if (arguments.length < 2) p = 0.45;
  if (arguments.length < 1) { a = 1; s = p / 4; }
  else s = p / (2 * Math.PI) * Math.asin(1 / a);
  return function(t) {
    return 1 + a * Math.pow(2, 10 * -t) * Math.sin((t - s) * 2 * Math.PI / p);
  };
}

function d3_ease_back(s) {
  if (!s) s = 1.70158;
  return function(t) {
    return t * t * ((s + 1) * t - s);
  };
}

function d3_ease_bounce(t) {
  return t < 1 / 2.75 ? 7.5625 * t * t
      : t < 2 / 2.75 ? 7.5625 * (t -= 1.5 / 2.75) * t + .75
      : t < 2.5 / 2.75 ? 7.5625 * (t -= 2.25 / 2.75) * t + .9375
      : 7.5625 * (t -= 2.625 / 2.75) * t + .984375;
}
d3.event = null;

function d3_eventCancel() {
  d3.event.stopPropagation();
  d3.event.preventDefault();
}
d3.interpolate = function(a, b) {
  var i = d3.interpolators.length, f;
  while (--i >= 0 && !(f = d3.interpolators[i](a, b)));
  return f;
};

d3.interpolateNumber = function(a, b) {
  b -= a;
  return function(t) { return a + b * t; };
};

d3.interpolateRound = function(a, b) {
  b -= a;
  return function(t) { return Math.round(a + b * t); };
};

d3.interpolateString = function(a, b) {
  var m, // current match
      i, // current index
      j, // current index (for coallescing)
      s0 = 0, // start index of current string prefix
      s1 = 0, // end index of current string prefix
      s = [], // string constants and placeholders
      q = [], // number interpolators
      n, // q.length
      o;

  // Reset our regular expression!
  d3_interpolate_number.lastIndex = 0;

  // Find all numbers in b.
  for (i = 0; m = d3_interpolate_number.exec(b); ++i) {
    if (m.index) s.push(b.substring(s0, s1 = m.index));
    q.push({i: s.length, x: m[0]});
    s.push(null);
    s0 = d3_interpolate_number.lastIndex;
  }
  if (s0 < b.length) s.push(b.substring(s0));

  // Find all numbers in a.
  for (i = 0, n = q.length; (m = d3_interpolate_number.exec(a)) && i < n; ++i) {
    o = q[i];
    if (o.x == m[0]) { // The numbers match, so coallesce.
      if (o.i) {
        if (s[o.i + 1] == null) { // This match is followed by another number.
          s[o.i - 1] += o.x;
          s.splice(o.i, 1);
          for (j = i + 1; j < n; ++j) q[j].i--;
        } else { // This match is followed by a string, so coallesce twice.
          s[o.i - 1] += o.x + s[o.i + 1];
          s.splice(o.i, 2);
          for (j = i + 1; j < n; ++j) q[j].i -= 2;
        }
      } else {
          if (s[o.i + 1] == null) { // This match is followed by another number.
          s[o.i] = o.x;
        } else { // This match is followed by a string, so coallesce twice.
          s[o.i] = o.x + s[o.i + 1];
          s.splice(o.i + 1, 1);
          for (j = i + 1; j < n; ++j) q[j].i--;
        }
      }
      q.splice(i, 1);
      n--;
      i--;
    } else {
      o.x = d3.interpolateNumber(parseFloat(m[0]), parseFloat(o.x));
    }
  }

  // Remove any numbers in b not found in a.
  while (i < n) {
    o = q.pop();
    if (s[o.i + 1] == null) { // This match is followed by another number.
      s[o.i] = o.x;
    } else { // This match is followed by a string, so coallesce twice.
      s[o.i] = o.x + s[o.i + 1];
      s.splice(o.i + 1, 1);
    }
    n--;
  }

  // Special optimization for only a single match.
  if (s.length === 1) {
    return s[0] == null ? q[0].x : function() { return b; };
  }

  // Otherwise, interpolate each of the numbers and rejoin the string.
  return function(t) {
    for (i = 0; i < n; ++i) s[(o = q[i]).i] = o.x(t);
    return s.join("");
  };
};

d3.interpolateTransform = function(a, b) {
  var s = [], // string constants and placeholders
      q = [], // number interpolators
      n,
      A = d3.transform(a),
      B = d3.transform(b),
      ta = A.translate,
      tb = B.translate,
      ra = A.rotate,
      rb = B.rotate,
      wa = A.skew,
      wb = B.skew,
      ka = A.scale,
      kb = B.scale;

  if (ta[0] != tb[0] || ta[1] != tb[1]) {
    s.push("translate(", null, ",", null, ")");
    q.push({i: 1, x: d3.interpolateNumber(ta[0], tb[0])}, {i: 3, x: d3.interpolateNumber(ta[1], tb[1])});
  } else if (tb[0] || tb[1]) {
    s.push("translate(" + tb + ")");
  } else {
    s.push("");
  }

  if (ra != rb) {
    q.push({i: s.push(s.pop() + "rotate(", null, ")") - 2, x: d3.interpolateNumber(ra, rb)});
  } else if (rb) {
    s.push(s.pop() + "rotate(" + rb + ")");
  }

  if (wa != wb) {
    q.push({i: s.push(s.pop() + "skewX(", null, ")") - 2, x: d3.interpolateNumber(wa, wb)});
  } else if (wb) {
    s.push(s.pop() + "skewX(" + wb + ")");
  }

  if (ka[0] != kb[0] || ka[1] != kb[1]) {
    n = s.push(s.pop() + "scale(", null, ",", null, ")");
    q.push({i: n - 4, x: d3.interpolateNumber(ka[0], kb[0])}, {i: n - 2, x: d3.interpolateNumber(ka[1], kb[1])});
  } else if (kb[0] != 1 || kb[1] != 1) {
    s.push(s.pop() + "scale(" + kb + ")");
  }

  n = q.length;
  return function(t) {
    var i = -1, o;
    while (++i < n) s[(o = q[i]).i] = o.x(t);
    return s.join("");
  };
};

d3.interpolateRgb = function(a, b) {
  a = d3.rgb(a);
  b = d3.rgb(b);
  var ar = a.r,
      ag = a.g,
      ab = a.b,
      br = b.r - ar,
      bg = b.g - ag,
      bb = b.b - ab;
  return function(t) {
    return "#"
        + d3_rgb_hex(Math.round(ar + br * t))
        + d3_rgb_hex(Math.round(ag + bg * t))
        + d3_rgb_hex(Math.round(ab + bb * t));
  };
};

// interpolates HSL space, but outputs RGB string (for compatibility)
d3.interpolateHsl = function(a, b) {
  a = d3.hsl(a);
  b = d3.hsl(b);
  var h0 = a.h,
      s0 = a.s,
      l0 = a.l,
      h1 = b.h - h0,
      s1 = b.s - s0,
      l1 = b.l - l0;
  return function(t) {
    return d3_hsl_rgb(h0 + h1 * t, s0 + s1 * t, l0 + l1 * t).toString();
  };
};

d3.interpolateArray = function(a, b) {
  var x = [],
      c = [],
      na = a.length,
      nb = b.length,
      n0 = Math.min(a.length, b.length),
      i;
  for (i = 0; i < n0; ++i) x.push(d3.interpolate(a[i], b[i]));
  for (; i < na; ++i) c[i] = a[i];
  for (; i < nb; ++i) c[i] = b[i];
  return function(t) {
    for (i = 0; i < n0; ++i) c[i] = x[i](t);
    return c;
  };
};

d3.interpolateObject = function(a, b) {
  var i = {},
      c = {},
      k;
  for (k in a) {
    if (k in b) {
      i[k] = d3_interpolateByName(k)(a[k], b[k]);
    } else {
      c[k] = a[k];
    }
  }
  for (k in b) {
    if (!(k in a)) {
      c[k] = b[k];
    }
  }
  return function(t) {
    for (k in i) c[k] = i[k](t);
    return c;
  };
}

var d3_interpolate_number = /[-+]?(?:\d*\.?\d+)(?:[eE][-+]?\d+)?/g;

function d3_interpolateByName(n) {
  return n == "transform"
      ? d3.interpolateTransform
      : d3.interpolate;
}

d3.interpolators = [
  d3.interpolateObject,
  function(a, b) { return (b instanceof Array) && d3.interpolateArray(a, b); },
  function(a, b) { return (typeof a === "string" || typeof b === "string") && d3.interpolateString(a + "", b + ""); },
  function(a, b) { return (typeof b === "string" ? b in d3_rgb_names || /^(#|rgb\(|hsl\()/.test(b) : b instanceof d3_Rgb || b instanceof d3_Hsl) && d3.interpolateRgb(a, b); },
  function(a, b) { return !isNaN(a = +a) && !isNaN(b = +b) && d3.interpolateNumber(a, b); }
];
function d3_uninterpolateNumber(a, b) {
  b = b - (a = +a) ? 1 / (b - a) : 0;
  return function(x) { return (x - a) * b; };
}

function d3_uninterpolateClamp(a, b) {
  b = b - (a = +a) ? 1 / (b - a) : 0;
  return function(x) { return Math.max(0, Math.min(1, (x - a) * b)); };
}
d3.rgb = function(r, g, b) {
  return arguments.length === 1
      ? (r instanceof d3_Rgb ? d3_rgb(r.r, r.g, r.b)
      : d3_rgb_parse("" + r, d3_rgb, d3_hsl_rgb))
      : d3_rgb(~~r, ~~g, ~~b);
};

function d3_rgb(r, g, b) {
  return new d3_Rgb(r, g, b);
}

function d3_Rgb(r, g, b) {
  this.r = r;
  this.g = g;
  this.b = b;
}

d3_Rgb.prototype.brighter = function(k) {
  k = Math.pow(0.7, arguments.length ? k : 1);
  var r = this.r,
      g = this.g,
      b = this.b,
      i = 30;
  if (!r && !g && !b) return d3_rgb(i, i, i);
  if (r && r < i) r = i;
  if (g && g < i) g = i;
  if (b && b < i) b = i;
  return d3_rgb(
      Math.min(255, Math.floor(r / k)),
      Math.min(255, Math.floor(g / k)),
      Math.min(255, Math.floor(b / k)));
};

d3_Rgb.prototype.darker = function(k) {
  k = Math.pow(0.7, arguments.length ? k : 1);
  return d3_rgb(
      Math.floor(k * this.r),
      Math.floor(k * this.g),
      Math.floor(k * this.b));
};

d3_Rgb.prototype.hsl = function() {
  return d3_rgb_hsl(this.r, this.g, this.b);
};

d3_Rgb.prototype.toString = function() {
  return "#" + d3_rgb_hex(this.r) + d3_rgb_hex(this.g) + d3_rgb_hex(this.b);
};

function d3_rgb_hex(v) {
  return v < 0x10
      ? "0" + Math.max(0, v).toString(16)
      : Math.min(255, v).toString(16);
}

function d3_rgb_parse(format, rgb, hsl) {
  var r = 0, // red channel; int in [0, 255]
      g = 0, // green channel; int in [0, 255]
      b = 0, // blue channel; int in [0, 255]
      m1, // CSS color specification match
      m2, // CSS color specification type (e.g., rgb)
      name;

  /* Handle hsl, rgb. */
  m1 = /([a-z]+)\((.*)\)/i.exec(format);
  if (m1) {
    m2 = m1[2].split(",");
    switch (m1[1]) {
      case "hsl": {
        return hsl(
          parseFloat(m2[0]), // degrees
          parseFloat(m2[1]) / 100, // percentage
          parseFloat(m2[2]) / 100 // percentage
        );
      }
      case "rgb": {
        return rgb(
          d3_rgb_parseNumber(m2[0]),
          d3_rgb_parseNumber(m2[1]),
          d3_rgb_parseNumber(m2[2])
        );
      }
    }
  }

  /* Named colors. */
  if (name = d3_rgb_names[format]) return rgb(name.r, name.g, name.b);

  /* Hexadecimal colors: #rgb and #rrggbb. */
  if (format != null && format.charAt(0) === "#") {
    if (format.length === 4) {
      r = format.charAt(1); r += r;
      g = format.charAt(2); g += g;
      b = format.charAt(3); b += b;
    } else if (format.length === 7) {
      r = format.substring(1, 3);
      g = format.substring(3, 5);
      b = format.substring(5, 7);
    }
    r = parseInt(r, 16);
    g = parseInt(g, 16);
    b = parseInt(b, 16);
  }

  return rgb(r, g, b);
}

function d3_rgb_hsl(r, g, b) {
  var min = Math.min(r /= 255, g /= 255, b /= 255),
      max = Math.max(r, g, b),
      d = max - min,
      h,
      s,
      l = (max + min) / 2;
  if (d) {
    s = l < .5 ? d / (max + min) : d / (2 - max - min);
    if (r == max) h = (g - b) / d + (g < b ? 6 : 0);
    else if (g == max) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    h *= 60;
  } else {
    s = h = 0;
  }
  return d3_hsl(h, s, l);
}

function d3_rgb_parseNumber(c) { // either integer or percentage
  var f = parseFloat(c);
  return c.charAt(c.length - 1) === "%" ? Math.round(f * 2.55) : f;
}

var d3_rgb_names = {
  aliceblue: "#f0f8ff",
  antiquewhite: "#faebd7",
  aqua: "#00ffff",
  aquamarine: "#7fffd4",
  azure: "#f0ffff",
  beige: "#f5f5dc",
  bisque: "#ffe4c4",
  black: "#000000",
  blanchedalmond: "#ffebcd",
  blue: "#0000ff",
  blueviolet: "#8a2be2",
  brown: "#a52a2a",
  burlywood: "#deb887",
  cadetblue: "#5f9ea0",
  chartreuse: "#7fff00",
  chocolate: "#d2691e",
  coral: "#ff7f50",
  cornflowerblue: "#6495ed",
  cornsilk: "#fff8dc",
  crimson: "#dc143c",
  cyan: "#00ffff",
  darkblue: "#00008b",
  darkcyan: "#008b8b",
  darkgoldenrod: "#b8860b",
  darkgray: "#a9a9a9",
  darkgreen: "#006400",
  darkgrey: "#a9a9a9",
  darkkhaki: "#bdb76b",
  darkmagenta: "#8b008b",
  darkolivegreen: "#556b2f",
  darkorange: "#ff8c00",
  darkorchid: "#9932cc",
  darkred: "#8b0000",
  darksalmon: "#e9967a",
  darkseagreen: "#8fbc8f",
  darkslateblue: "#483d8b",
  darkslategray: "#2f4f4f",
  darkslategrey: "#2f4f4f",
  darkturquoise: "#00ced1",
  darkviolet: "#9400d3",
  deeppink: "#ff1493",
  deepskyblue: "#00bfff",
  dimgray: "#696969",
  dimgrey: "#696969",
  dodgerblue: "#1e90ff",
  firebrick: "#b22222",
  floralwhite: "#fffaf0",
  forestgreen: "#228b22",
  fuchsia: "#ff00ff",
  gainsboro: "#dcdcdc",
  ghostwhite: "#f8f8ff",
  gold: "#ffd700",
  goldenrod: "#daa520",
  gray: "#808080",
  green: "#008000",
  greenyellow: "#adff2f",
  grey: "#808080",
  honeydew: "#f0fff0",
  hotpink: "#ff69b4",
  indianred: "#cd5c5c",
  indigo: "#4b0082",
  ivory: "#fffff0",
  khaki: "#f0e68c",
  lavender: "#e6e6fa",
  lavenderblush: "#fff0f5",
  lawngreen: "#7cfc00",
  lemonchiffon: "#fffacd",
  lightblue: "#add8e6",
  lightcoral: "#f08080",
  lightcyan: "#e0ffff",
  lightgoldenrodyellow: "#fafad2",
  lightgray: "#d3d3d3",
  lightgreen: "#90ee90",
  lightgrey: "#d3d3d3",
  lightpink: "#ffb6c1",
  lightsalmon: "#ffa07a",
  lightseagreen: "#20b2aa",
  lightskyblue: "#87cefa",
  lightslategray: "#778899",
  lightslategrey: "#778899",
  lightsteelblue: "#b0c4de",
  lightyellow: "#ffffe0",
  lime: "#00ff00",
  limegreen: "#32cd32",
  linen: "#faf0e6",
  magenta: "#ff00ff",
  maroon: "#800000",
  mediumaquamarine: "#66cdaa",
  mediumblue: "#0000cd",
  mediumorchid: "#ba55d3",
  mediumpurple: "#9370db",
  mediumseagreen: "#3cb371",
  mediumslateblue: "#7b68ee",
  mediumspringgreen: "#00fa9a",
  mediumturquoise: "#48d1cc",
  mediumvioletred: "#c71585",
  midnightblue: "#191970",
  mintcream: "#f5fffa",
  mistyrose: "#ffe4e1",
  moccasin: "#ffe4b5",
  navajowhite: "#ffdead",
  navy: "#000080",
  oldlace: "#fdf5e6",
  olive: "#808000",
  olivedrab: "#6b8e23",
  orange: "#ffa500",
  orangered: "#ff4500",
  orchid: "#da70d6",
  palegoldenrod: "#eee8aa",
  palegreen: "#98fb98",
  paleturquoise: "#afeeee",
  palevioletred: "#db7093",
  papayawhip: "#ffefd5",
  peachpuff: "#ffdab9",
  peru: "#cd853f",
  pink: "#ffc0cb",
  plum: "#dda0dd",
  powderblue: "#b0e0e6",
  purple: "#800080",
  red: "#ff0000",
  rosybrown: "#bc8f8f",
  royalblue: "#4169e1",
  saddlebrown: "#8b4513",
  salmon: "#fa8072",
  sandybrown: "#f4a460",
  seagreen: "#2e8b57",
  seashell: "#fff5ee",
  sienna: "#a0522d",
  silver: "#c0c0c0",
  skyblue: "#87ceeb",
  slateblue: "#6a5acd",
  slategray: "#708090",
  slategrey: "#708090",
  snow: "#fffafa",
  springgreen: "#00ff7f",
  steelblue: "#4682b4",
  tan: "#d2b48c",
  teal: "#008080",
  thistle: "#d8bfd8",
  tomato: "#ff6347",
  turquoise: "#40e0d0",
  violet: "#ee82ee",
  wheat: "#f5deb3",
  white: "#ffffff",
  whitesmoke: "#f5f5f5",
  yellow: "#ffff00",
  yellowgreen: "#9acd32"
};

for (var d3_rgb_name in d3_rgb_names) {
  d3_rgb_names[d3_rgb_name] = d3_rgb_parse(
      d3_rgb_names[d3_rgb_name],
      d3_rgb,
      d3_hsl_rgb);
}
d3.hsl = function(h, s, l) {
  return arguments.length === 1
      ? (h instanceof d3_Hsl ? d3_hsl(h.h, h.s, h.l)
      : d3_rgb_parse("" + h, d3_rgb_hsl, d3_hsl))
      : d3_hsl(+h, +s, +l);
};

function d3_hsl(h, s, l) {
  return new d3_Hsl(h, s, l);
}

function d3_Hsl(h, s, l) {
  this.h = h;
  this.s = s;
  this.l = l;
}

d3_Hsl.prototype.brighter = function(k) {
  k = Math.pow(0.7, arguments.length ? k : 1);
  return d3_hsl(this.h, this.s, this.l / k);
};

d3_Hsl.prototype.darker = function(k) {
  k = Math.pow(0.7, arguments.length ? k : 1);
  return d3_hsl(this.h, this.s, k * this.l);
};

d3_Hsl.prototype.rgb = function() {
  return d3_hsl_rgb(this.h, this.s, this.l);
};

d3_Hsl.prototype.toString = function() {
  return this.rgb().toString();
};

function d3_hsl_rgb(h, s, l) {
  var m1,
      m2;

  /* Some simple corrections for h, s and l. */
  h = h % 360; if (h < 0) h += 360;
  s = s < 0 ? 0 : s > 1 ? 1 : s;
  l = l < 0 ? 0 : l > 1 ? 1 : l;

  /* From FvD 13.37, CSS Color Module Level 3 */
  m2 = l <= .5 ? l * (1 + s) : l + s - l * s;
  m1 = 2 * l - m2;

  function v(h) {
    if (h > 360) h -= 360;
    else if (h < 0) h += 360;
    if (h < 60) return m1 + (m2 - m1) * h / 60;
    if (h < 180) return m2;
    if (h < 240) return m1 + (m2 - m1) * (240 - h) / 60;
    return m1;
  }

  function vv(h) {
    return Math.round(v(h) * 255);
  }

  return d3_rgb(vv(h + 120), vv(h), vv(h - 120));
}
function d3_selection(groups) {
  d3_arraySubclass(groups, d3_selectionPrototype);
  return groups;
}

var d3_select = function(s, n) { return n.querySelector(s); },
    d3_selectAll = function(s, n) { return n.querySelectorAll(s); },
    d3_selectRoot = document.documentElement,
    d3_selectMatcher = d3_selectRoot.matchesSelector || d3_selectRoot.webkitMatchesSelector || d3_selectRoot.mozMatchesSelector || d3_selectRoot.msMatchesSelector || d3_selectRoot.oMatchesSelector,
    d3_selectMatches = function(n, s) { return d3_selectMatcher.call(n, s); };

// Prefer Sizzle, if available.
if (typeof Sizzle === "function") {
  d3_select = function(s, n) { return Sizzle(s, n)[0]; };
  d3_selectAll = function(s, n) { return Sizzle.uniqueSort(Sizzle(s, n)); };
  d3_selectMatches = Sizzle.matchesSelector;
}

var d3_selectionPrototype = [];

d3.selection = function() {
  return d3_selectionRoot;
};

d3.selection.prototype = d3_selectionPrototype;
d3_selectionPrototype.select = function(selector) {
  var subgroups = [],
      subgroup,
      subnode,
      group,
      node;

  if (typeof selector !== "function") selector = d3_selection_selector(selector);

  for (var j = -1, m = this.length; ++j < m;) {
    subgroups.push(subgroup = []);
    subgroup.parentNode = (group = this[j]).parentNode;
    for (var i = -1, n = group.length; ++i < n;) {
      if (node = group[i]) {
        subgroup.push(subnode = selector.call(node, node.__data__, i));
        if (subnode && "__data__" in node) subnode.__data__ = node.__data__;
      } else {
        subgroup.push(null);
      }
    }
  }

  return d3_selection(subgroups);
};

function d3_selection_selector(selector) {
  return function() {
    return d3_select(selector, this);
  };
}
d3_selectionPrototype.selectAll = function(selector) {
  var subgroups = [],
      subgroup,
      node;

  if (typeof selector !== "function") selector = d3_selection_selectorAll(selector);

  for (var j = -1, m = this.length; ++j < m;) {
    for (var group = this[j], i = -1, n = group.length; ++i < n;) {
      if (node = group[i]) {
        subgroups.push(subgroup = d3_array(selector.call(node, node.__data__, i)));
        subgroup.parentNode = node;
      }
    }
  }

  return d3_selection(subgroups);
};

function d3_selection_selectorAll(selector) {
  return function() {
    return d3_selectAll(selector, this);
  };
}
d3_selectionPrototype.attr = function(name, value) {
  name = d3.ns.qualify(name);

  // If no value is specified, return the first value.
  if (arguments.length < 2) {
    var node = this.node();
    return name.local
        ? node.getAttributeNS(name.space, name.local)
        : node.getAttribute(name);
  }

  function attrNull() {
    this.removeAttribute(name);
  }

  function attrNullNS() {
    this.removeAttributeNS(name.space, name.local);
  }

  function attrConstant() {
    this.setAttribute(name, value);
  }

  function attrConstantNS() {
    this.setAttributeNS(name.space, name.local, value);
  }

  function attrFunction() {
    var x = value.apply(this, arguments);
    if (x == null) this.removeAttribute(name);
    else this.setAttribute(name, x);
  }

  function attrFunctionNS() {
    var x = value.apply(this, arguments);
    if (x == null) this.removeAttributeNS(name.space, name.local);
    else this.setAttributeNS(name.space, name.local, x);
  }

  return this.each(value == null
      ? (name.local ? attrNullNS : attrNull) : (typeof value === "function"
      ? (name.local ? attrFunctionNS : attrFunction)
      : (name.local ? attrConstantNS : attrConstant)));
};
d3_selectionPrototype.classed = function(name, value) {
  var names = name.split(d3_selection_classedWhitespace),
      n = names.length,
      i = -1;
  if (arguments.length > 1) {
    while (++i < n) d3_selection_classed.call(this, names[i], value);
    return this;
  } else {
    while (++i < n) if (!d3_selection_classed.call(this, names[i])) return false;
    return true;
  }
};

var d3_selection_classedWhitespace = /\s+/g;

function d3_selection_classed(name, value) {
  var re = new RegExp("(^|\\s+)" + d3.requote(name) + "(\\s+|$)", "g");

  // If no value is specified, return the first value.
  if (arguments.length < 2) {
    var node = this.node();
    if (c = node.classList) return c.contains(name);
    var c = node.className;
    re.lastIndex = 0;
    return re.test(c.baseVal != null ? c.baseVal : c);
  }

  function classedAdd() {
    if (c = this.classList) return c.add(name);
    var c = this.className,
        cb = c.baseVal != null,
        cv = cb ? c.baseVal : c;
    re.lastIndex = 0;
    if (!re.test(cv)) {
      cv = d3_collapse(cv + " " + name);
      if (cb) c.baseVal = cv;
      else this.className = cv;
    }
  }

  function classedRemove() {
    if (c = this.classList) return c.remove(name);
    var c = this.className,
        cb = c.baseVal != null,
        cv = cb ? c.baseVal : c;
    cv = d3_collapse(cv.replace(re, " "));
    if (cb) c.baseVal = cv;
    else this.className = cv;
  }

  function classedFunction() {
    (value.apply(this, arguments)
        ? classedAdd
        : classedRemove).call(this);
  }

  return this.each(typeof value === "function"
      ? classedFunction : value
      ? classedAdd
      : classedRemove);
}
d3_selectionPrototype.style = function(name, value, priority) {
  if (arguments.length < 3) priority = "";

  // If no value is specified, return the first value.
  if (arguments.length < 2) return window
      .getComputedStyle(this.node(), null)
      .getPropertyValue(name);

  function styleNull() {
    this.style.removeProperty(name);
  }

  function styleConstant() {
    this.style.setProperty(name, value, priority);
  }

  function styleFunction() {
    var x = value.apply(this, arguments);
    if (x == null) this.style.removeProperty(name);
    else this.style.setProperty(name, x, priority);
  }

  return this.each(value == null
      ? styleNull : (typeof value === "function"
      ? styleFunction : styleConstant));
};
d3_selectionPrototype.property = function(name, value) {

  // If no value is specified, return the first value.
  if (arguments.length < 2) return this.node()[name];

  function propertyNull() {
    delete this[name];
  }

  function propertyConstant() {
    this[name] = value;
  }

  function propertyFunction() {
    var x = value.apply(this, arguments);
    if (x == null) delete this[name];
    else this[name] = x;
  }

  return this.each(value == null
      ? propertyNull : (typeof value === "function"
      ? propertyFunction : propertyConstant));
};
d3_selectionPrototype.text = function(value) {
  return arguments.length < 1
      ? this.node().textContent : this.each(typeof value === "function"
      ? function() { var v = value.apply(this, arguments); this.textContent = v == null ? "" : v; } : value == null
      ? function() { this.textContent = ""; }
      : function() { this.textContent = value; });
};
d3_selectionPrototype.html = function(value) {
  return arguments.length < 1
      ? this.node().innerHTML : this.each(typeof value === "function"
      ? function() { var v = value.apply(this, arguments); this.innerHTML = v == null ? "" : v; } : value == null
      ? function() { this.innerHTML = ""; }
      : function() { this.innerHTML = value; });
};
// TODO append(node)?
// TODO append(function)?
d3_selectionPrototype.append = function(name) {
  name = d3.ns.qualify(name);

  function append() {
    return this.appendChild(document.createElementNS(this.namespaceURI, name));
  }

  function appendNS() {
    return this.appendChild(document.createElementNS(name.space, name.local));
  }

  return this.select(name.local ? appendNS : append);
};
// TODO insert(node, function)?
// TODO insert(function, string)?
// TODO insert(function, function)?
d3_selectionPrototype.insert = function(name, before) {
  name = d3.ns.qualify(name);

  function insert() {
    return this.insertBefore(
        document.createElementNS(this.namespaceURI, name),
        d3_select(before, this));
  }

  function insertNS() {
    return this.insertBefore(
        document.createElementNS(name.space, name.local),
        d3_select(before, this));
  }

  return this.select(name.local ? insertNS : insert);
};
// TODO remove(selector)?
// TODO remove(node)?
// TODO remove(function)?
d3_selectionPrototype.remove = function() {
  return this.each(function() {
    var parent = this.parentNode;
    if (parent) parent.removeChild(this);
  });
};
// TODO data(null) for clearing data?
d3_selectionPrototype.data = function(data, join) {
  var enter = [],
      update = [],
      exit = [];

  function bind(group, groupData) {
    var i,
        n = group.length,
        m = groupData.length,
        n0 = Math.min(n, m),
        n1 = Math.max(n, m),
        updateNodes = [],
        enterNodes = [],
        exitNodes = [],
        node,
        nodeData;

    if (join) {
      var nodeByKey = {},
          keys = [],
          key,
          j = groupData.length;

      for (i = -1; ++i < n;) {
        key = join.call(node = group[i], node.__data__, i);
        if (key in nodeByKey) {
          exitNodes[j++] = node; // duplicate key
        } else {
          nodeByKey[key] = node;
        }
        keys.push(key);
      }

      for (i = -1; ++i < m;) {
        node = nodeByKey[key = join.call(groupData, nodeData = groupData[i], i)];
        if (node) {
          node.__data__ = nodeData;
          updateNodes[i] = node;
          enterNodes[i] = exitNodes[i] = null;
        } else {
          enterNodes[i] = d3_selection_dataNode(nodeData);
          updateNodes[i] = exitNodes[i] = null;
        }
        delete nodeByKey[key];
      }

      for (i = -1; ++i < n;) {
        if (keys[i] in nodeByKey) {
          exitNodes[i] = group[i];
        }
      }
    } else {
      for (i = -1; ++i < n0;) {
        node = group[i];
        nodeData = groupData[i];
        if (node) {
          node.__data__ = nodeData;
          updateNodes[i] = node;
          enterNodes[i] = exitNodes[i] = null;
        } else {
          enterNodes[i] = d3_selection_dataNode(nodeData);
          updateNodes[i] = exitNodes[i] = null;
        }
      }
      for (; i < m; ++i) {
        enterNodes[i] = d3_selection_dataNode(groupData[i]);
        updateNodes[i] = exitNodes[i] = null;
      }
      for (; i < n1; ++i) {
        exitNodes[i] = group[i];
        enterNodes[i] = updateNodes[i] = null;
      }
    }

    enterNodes.update
        = updateNodes;

    enterNodes.parentNode
        = updateNodes.parentNode
        = exitNodes.parentNode
        = group.parentNode;

    enter.push(enterNodes);
    update.push(updateNodes);
    exit.push(exitNodes);
  }

  var i = -1,
      n = this.length,
      group;
  if (typeof data === "function") {
    while (++i < n) {
      bind(group = this[i], data.call(group, group.parentNode.__data__, i));
    }
  } else {
    while (++i < n) {
      bind(group = this[i], data);
    }
  }

  var selection = d3_selection(update);
  selection.enter = function() { return d3_selection_enter(enter); };
  selection.exit = function() { return d3_selection(exit); };
  return selection;
};

function d3_selection_dataNode(data) {
  return {__data__: data};
}
d3_selectionPrototype.filter = function(filter) {
  var subgroups = [],
      subgroup,
      group,
      node;

  if (typeof filter !== "function") filter = d3_selection_filter(filter);

  for (var j = 0, m = this.length; j < m; j++) {
    subgroups.push(subgroup = []);
    subgroup.parentNode = (group = this[j]).parentNode;
    for (var i = 0, n = group.length; i < n; i++) {
      if ((node = group[i]) && filter.call(node, node.__data__, i)) {
        subgroup.push(node);
      }
    }
  }

  return d3_selection(subgroups);
};

function d3_selection_filter(selector) {
  return function() {
    return d3_selectMatches(this, selector);
  };
}
d3_selectionPrototype.map = function(map) {
  return this.each(function() {
    this.__data__ = map.apply(this, arguments);
  });
};
d3_selectionPrototype.order = function() {
  for (var j = -1, m = this.length; ++j < m;) {
    for (var group = this[j], i = group.length - 1, next = group[i], node; --i >= 0;) {
      if (node = group[i]) {
        if (next && next !== node.nextSibling) next.parentNode.insertBefore(node, next);
        next = node;
      }
    }
  }
  return this;
};
d3_selectionPrototype.sort = function(comparator) {
  comparator = d3_selection_sortComparator.apply(this, arguments);
  for (var j = -1, m = this.length; ++j < m;) this[j].sort(comparator);
  return this.order();
};

function d3_selection_sortComparator(comparator) {
  if (!arguments.length) comparator = d3.ascending;
  return function(a, b) {
    return comparator(a && a.__data__, b && b.__data__);
  };
}
// type can be namespaced, e.g., "click.foo"
// listener can be null for removal
d3_selectionPrototype.on = function(type, listener, capture) {
  if (arguments.length < 3) capture = false;

  // parse the type specifier
  var name = "__on" + type, i = type.indexOf(".");
  if (i > 0) type = type.substring(0, i);

  // if called with only one argument, return the current listener
  if (arguments.length < 2) return (i = this.node()[name]) && i._;

  // remove the old event listener, and add the new event listener
  return this.each(function(d, i) {
    var node = this;

    if (node[name]) node.removeEventListener(type, node[name], capture);
    if (listener) node.addEventListener(type, node[name] = l, capture);

    // wrapped event listener that preserves i
    function l(e) {
      var o = d3.event; // Events can be reentrant (e.g., focus).
      d3.event = e;
      try {
        listener.call(node, node.__data__, i);
      } finally {
        d3.event = o;
      }
    }

    // stash the unwrapped listener for retrieval
    l._ = listener;
  });
};
d3_selectionPrototype.each = function(callback) {
  for (var j = -1, m = this.length; ++j < m;) {
    for (var group = this[j], i = -1, n = group.length; ++i < n;) {
      var node = group[i];
      if (node) callback.call(node, node.__data__, i, j);
    }
  }
  return this;
};
//
// Note: assigning to the arguments array simultaneously changes the value of
// the corresponding argument!
//
// TODO The `this` argument probably shouldn't be the first argument to the
// callback, anyway, since it's redundant. However, that will require a major
// version bump due to backwards compatibility, so I'm not changing it right
// away.
//
d3_selectionPrototype.call = function(callback) {
  callback.apply(this, (arguments[0] = this, arguments));
  return this;
};
d3_selectionPrototype.empty = function() {
  return !this.node();
};
d3_selectionPrototype.node = function(callback) {
  for (var j = 0, m = this.length; j < m; j++) {
    for (var group = this[j], i = 0, n = group.length; i < n; i++) {
      var node = group[i];
      if (node) return node;
    }
  }
  return null;
};
d3_selectionPrototype.transition = function() {
  var subgroups = [],
      subgroup,
      node;

  for (var j = -1, m = this.length; ++j < m;) {
    subgroups.push(subgroup = []);
    for (var group = this[j], i = -1, n = group.length; ++i < n;) {
      subgroup.push((node = group[i]) ? {node: node, delay: 0, duration: 250} : null);
    }
  }

  return d3_transition(subgroups, d3_transitionInheritId || ++d3_transitionId, Date.now());
};
var d3_selectionRoot = d3_selection([[document]]);

d3_selectionRoot[0].parentNode = d3_selectRoot;

// TODO fast singleton implementation!
// TODO select(function)
d3.select = function(selector) {
  return typeof selector === "string"
      ? d3_selectionRoot.select(selector)
      : d3_selection([[selector]]); // assume node
};

// TODO selectAll(function)
d3.selectAll = function(selector) {
  return typeof selector === "string"
      ? d3_selectionRoot.selectAll(selector)
      : d3_selection([d3_array(selector)]); // assume node[]
};
function d3_selection_enter(selection) {
  d3_arraySubclass(selection, d3_selection_enterPrototype);
  return selection;
}

var d3_selection_enterPrototype = [];

d3_selection_enterPrototype.append = d3_selectionPrototype.append;
d3_selection_enterPrototype.insert = d3_selectionPrototype.insert;
d3_selection_enterPrototype.empty = d3_selectionPrototype.empty;
d3_selection_enterPrototype.node = d3_selectionPrototype.node;
d3_selection_enterPrototype.select = function(selector) {
  var subgroups = [],
      subgroup,
      subnode,
      upgroup,
      group,
      node;

  for (var j = -1, m = this.length; ++j < m;) {
    upgroup = (group = this[j]).update;
    subgroups.push(subgroup = []);
    subgroup.parentNode = group.parentNode;
    for (var i = -1, n = group.length; ++i < n;) {
      if (node = group[i]) {
        subgroup.push(upgroup[i] = subnode = selector.call(group.parentNode, node.__data__, i));
        subnode.__data__ = node.__data__;
      } else {
        subgroup.push(null);
      }
    }
  }

  return d3_selection(subgroups);
};
function d3_transition(groups, id, time) {
  d3_arraySubclass(groups, d3_transitionPrototype);

  var tweens = {},
      event = d3.dispatch("start", "end"),
      ease = d3_transitionEase;

  groups.id = id;

  groups.time = time;

  groups.tween = function(name, tween) {
    if (arguments.length < 2) return tweens[name];
    if (tween == null) delete tweens[name];
    else tweens[name] = tween;
    return groups;
  };

  groups.ease = function(value) {
    if (!arguments.length) return ease;
    ease = typeof value === "function" ? value : d3.ease.apply(d3, arguments);
    return groups;
  };

  groups.each = function(type, listener) {
    if (arguments.length < 2) return d3_transition_each.call(groups, type);
    event.on(type, listener);
    return groups;
  };

  d3.timer(function(elapsed) {
    groups.each(function(d, i, j) {
      var tweened = [],
          node = this,
          delay = groups[j][i].delay,
          duration = groups[j][i].duration,
          lock = node.__transition__ || (node.__transition__ = {active: 0, count: 0});

      ++lock.count;

      delay <= elapsed ? start(elapsed) : d3.timer(start, delay, time);

      function start(elapsed) {
        if (lock.active > id) return stop();
        lock.active = id;

        for (var tween in tweens) {
          if (tween = tweens[tween].call(node, d, i)) {
            tweened.push(tween);
          }
        }

        event.start.call(node, d, i);
        if (!tick(elapsed)) d3.timer(tick, 0, time);
        return 1;
      }

      function tick(elapsed) {
        if (lock.active !== id) return stop();

        var t = (elapsed - delay) / duration,
            e = ease(t),
            n = tweened.length;

        while (n > 0) {
          tweened[--n].call(node, e);
        }

        if (t >= 1) {
          stop();
          d3_transitionInheritId = id;
          event.end.call(node, d, i);
          d3_transitionInheritId = 0;
          return 1;
        }
      }

      function stop() {
        if (!--lock.count) delete node.__transition__;
        return 1;
      }
    });
    return 1;
  }, 0, time);

  return groups;
}

var d3_transitionRemove = {};

function d3_transitionNull(d, i, a) {
  return a != "" && d3_transitionRemove;
}

function d3_transitionTween(name, b) {
  var interpolate = d3_interpolateByName(name);

  function transitionFunction(d, i, a) {
    var v = b.call(this, d, i);
    return v == null
        ? a != "" && d3_transitionRemove
        : a != v && interpolate(a, v);
  }

  function transitionString(d, i, a) {
    return a != b && interpolate(a, b);
  }

  return typeof b === "function" ? transitionFunction
      : b == null ? d3_transitionNull
      : (b += "", transitionString);
}

var d3_transitionPrototype = [],
    d3_transitionId = 0,
    d3_transitionInheritId = 0,
    d3_transitionEase = d3.ease("cubic-in-out");

d3_transitionPrototype.call = d3_selectionPrototype.call;

d3.transition = function() {
  return d3_selectionRoot.transition();
};

d3.transition.prototype = d3_transitionPrototype;
d3_transitionPrototype.select = function(selector) {
  var subgroups = [],
      subgroup,
      subnode,
      node;

  if (typeof selector !== "function") selector = d3_selection_selector(selector);

  for (var j = -1, m = this.length; ++j < m;) {
    subgroups.push(subgroup = []);
    for (var group = this[j], i = -1, n = group.length; ++i < n;) {
      if ((node = group[i]) && (subnode = selector.call(node.node, node.node.__data__, i))) {
        if ("__data__" in node.node) subnode.__data__ = node.node.__data__;
        subgroup.push({node: subnode, delay: node.delay, duration: node.duration});
      } else {
        subgroup.push(null);
      }
    }
  }

  return d3_transition(subgroups, this.id, this.time).ease(this.ease());
};
d3_transitionPrototype.selectAll = function(selector) {
  var subgroups = [],
      subgroup,
      subnodes,
      node;

  if (typeof selector !== "function") selector = d3_selection_selectorAll(selector);

  for (var j = -1, m = this.length; ++j < m;) {
    for (var group = this[j], i = -1, n = group.length; ++i < n;) {
      if (node = group[i]) {
        subnodes = selector.call(node.node, node.node.__data__, i);
        subgroups.push(subgroup = []);
        for (var k = -1, o = subnodes.length; ++k < o;) {
          subgroup.push({node: subnodes[k], delay: node.delay, duration: node.duration});
        }
      }
    }
  }

  return d3_transition(subgroups, this.id, this.time).ease(this.ease());
};
d3_transitionPrototype.attr = function(name, value) {
  return this.attrTween(name, d3_transitionTween(name, value));
};

d3_transitionPrototype.attrTween = function(nameNS, tween) {
  var name = d3.ns.qualify(nameNS);

  function attrTween(d, i) {
    var f = tween.call(this, d, i, this.getAttribute(name));
    return f === d3_transitionRemove
        ? (this.removeAttribute(name), null)
        : f && function(t) { this.setAttribute(name, f(t)); };
  }

  function attrTweenNS(d, i) {
    var f = tween.call(this, d, i, this.getAttributeNS(name.space, name.local));
    return f === d3_transitionRemove
        ? (this.removeAttributeNS(name.space, name.local), null)
        : f && function(t) { this.setAttributeNS(name.space, name.local, f(t)); };
  }

  return this.tween("attr." + nameNS, name.local ? attrTweenNS : attrTween);
};
d3_transitionPrototype.style = function(name, value, priority) {
  if (arguments.length < 3) priority = "";
  return this.styleTween(name, d3_transitionTween(name, value), priority);
};

d3_transitionPrototype.styleTween = function(name, tween, priority) {
  if (arguments.length < 3) priority = "";
  return this.tween("style." + name, function(d, i) {
    var f = tween.call(this, d, i, window.getComputedStyle(this, null).getPropertyValue(name));
    return f === d3_transitionRemove
        ? (this.style.removeProperty(name), null)
        : f && function(t) { this.style.setProperty(name, f(t), priority); };
  });
};
d3_transitionPrototype.text = function(value) {
  return this.tween("text", function(d, i) {
    this.textContent = typeof value === "function"
        ? value.call(this, d, i)
        : value;
  });
};
d3_transitionPrototype.remove = function() {
  return this.each("end.transition", function() {
    var p;
    if (!this.__transition__ && (p = this.parentNode)) p.removeChild(this);
  });
};
d3_transitionPrototype.delay = function(value) {
  var groups = this;
  return groups.each(typeof value === "function"
      ? function(d, i, j) { groups[j][i].delay = +value.apply(this, arguments); }
      : (value = +value, function(d, i, j) { groups[j][i].delay = value; }));
};
d3_transitionPrototype.duration = function(value) {
  var groups = this;
  return groups.each(typeof value === "function"
      ? function(d, i, j) { groups[j][i].duration = +value.apply(this, arguments); }
      : (value = +value, function(d, i, j) { groups[j][i].duration = value; }));
};
function d3_transition_each(callback) {
  for (var j = 0, m = this.length; j < m; j++) {
    for (var group = this[j], i = 0, n = group.length; i < n; i++) {
      var node = group[i];
      if (node) callback.call(node = node.node, node.__data__, i, j);
    }
  }
  return this;
}
d3_transitionPrototype.transition = function() {
  return this.select(d3_this);
};
var d3_timer_queue = null,
    d3_timer_interval, // is an interval (or frame) active?
    d3_timer_timeout; // is a timeout active?

// The timer will continue to fire until callback returns true.
d3.timer = function(callback, delay, then) {
  var found = false,
      t0,
      t1 = d3_timer_queue;

  if (arguments.length < 3) {
    if (arguments.length < 2) delay = 0;
    else if (!isFinite(delay)) return;
    then = Date.now();
  }

  // See if the callback's already in the queue.
  while (t1) {
    if (t1.callback === callback) {
      t1.then = then;
      t1.delay = delay;
      found = true;
      break;
    }
    t0 = t1;
    t1 = t1.next;
  }

  // Otherwise, add the callback to the queue.
  if (!found) d3_timer_queue = {
    callback: callback,
    then: then,
    delay: delay,
    next: d3_timer_queue
  };

  // Start animatin'!
  if (!d3_timer_interval) {
    d3_timer_timeout = clearTimeout(d3_timer_timeout);
    d3_timer_interval = 1;
    d3_timer_frame(d3_timer_step);
  }
}

function d3_timer_step() {
  var elapsed,
      now = Date.now(),
      t1 = d3_timer_queue;

  while (t1) {
    elapsed = now - t1.then;
    if (elapsed >= t1.delay) t1.flush = t1.callback(elapsed);
    t1 = t1.next;
  }

  var delay = d3_timer_flush() - now;
  if (delay > 24) {
    if (isFinite(delay)) {
      clearTimeout(d3_timer_timeout);
      d3_timer_timeout = setTimeout(d3_timer_step, delay);
    }
    d3_timer_interval = 0;
  } else {
    d3_timer_interval = 1;
    d3_timer_frame(d3_timer_step);
  }
}

d3.timer.flush = function() {
  var elapsed,
      now = Date.now(),
      t1 = d3_timer_queue;

  while (t1) {
    elapsed = now - t1.then;
    if (!t1.delay) t1.flush = t1.callback(elapsed);
    t1 = t1.next;
  }

  d3_timer_flush();
};

// Flush after callbacks, to avoid concurrent queue modification.
function d3_timer_flush() {
  var t0 = null,
      t1 = d3_timer_queue,
      then = Infinity;
  while (t1) {
    if (t1.flush) {
      t1 = t0 ? t0.next = t1.next : d3_timer_queue = t1.next;
    } else {
      then = Math.min(then, t1.then + t1.delay);
      t1 = (t0 = t1).next;
    }
  }
  return then;
}

var d3_timer_frame = window.requestAnimationFrame
    || window.webkitRequestAnimationFrame
    || window.mozRequestAnimationFrame
    || window.oRequestAnimationFrame
    || window.msRequestAnimationFrame
    || function(callback) { setTimeout(callback, 17); };
d3.transform = function(string) {
  var g = document.createElementNS(d3.ns.prefix.svg, "g"),
      identity = {a: 1, b: 0, c: 0, d: 1, e: 0, f: 0};
  return (d3.transform = function(string) {
    g.setAttribute("transform", string);
    var t = g.transform.baseVal.consolidate();
    return new d3_transform(t ? t.matrix : identity);
  })(string);
};

// Compute x-scale and normalize the first row.
// Compute shear and make second row orthogonal to first.
// Compute y-scale and normalize the second row.
// Finally, compute the rotation.
function d3_transform(m) {
  var r0 = [m.a, m.b],
      r1 = [m.c, m.d],
      kx = d3_transformNormalize(r0),
      kz = d3_transformDot(r0, r1),
      ky = d3_transformNormalize(d3_transformCombine(r1, r0, -kz)) || 0;
  if (r0[0] * r1[1] < r1[0] * r0[1]) {
    r0[0] *= -1;
    r0[1] *= -1;
    kx *= -1;
    kz *= -1;
  }
  this.rotate = (kx ? Math.atan2(r0[1], r0[0]) : Math.atan2(-r1[0], r1[1])) * d3_transformDegrees;
  this.translate = [m.e, m.f];
  this.scale = [kx, ky];
  this.skew = ky ? Math.atan2(kz, ky) * d3_transformDegrees : 0;
};

d3_transform.prototype.toString = function() {
  return "translate(" + this.translate
      + ")rotate(" + this.rotate
      + ")skewX(" + this.skew
      + ")scale(" + this.scale
      + ")";
};

function d3_transformDot(a, b) {
  return a[0] * b[0] + a[1] * b[1];
}

function d3_transformNormalize(a) {
  var k = Math.sqrt(d3_transformDot(a, a));
  if (k) {
    a[0] /= k;
    a[1] /= k;
  }
  return k;
}

function d3_transformCombine(a, b, k) {
  a[0] += k * b[0];
  a[1] += k * b[1];
  return a;
}

var d3_transformDegrees = 180 / Math.PI;
function d3_noop() {}
d3.scale = {};

function d3_scaleExtent(domain) {
  var start = domain[0], stop = domain[domain.length - 1];
  return start < stop ? [start, stop] : [stop, start];
}

function d3_scaleRange(scale) {
  return scale.rangeExtent ? scale.rangeExtent() : d3_scaleExtent(scale.range());
}
function d3_scale_nice(domain, nice) {
  var i0 = 0,
      i1 = domain.length - 1,
      x0 = domain[i0],
      x1 = domain[i1],
      dx;

  if (x1 < x0) {
    dx = i0; i0 = i1; i1 = dx;
    dx = x0; x0 = x1; x1 = dx;
  }

  if (dx = x1 - x0) {
    nice = nice(dx);
    domain[i0] = nice.floor(x0);
    domain[i1] = nice.ceil(x1);
  }

  return domain;
}

function d3_scale_niceDefault() {
  return Math;
}
d3.scale.linear = function() {
  return d3_scale_linear([0, 1], [0, 1], d3.interpolate, false);
};

function d3_scale_linear(domain, range, interpolate, clamp) {
  var output,
      input;

  function rescale() {
    var linear = domain.length == 2 ? d3_scale_bilinear : d3_scale_polylinear,
        uninterpolate = clamp ? d3_uninterpolateClamp : d3_uninterpolateNumber;
    output = linear(domain, range, uninterpolate, interpolate);
    input = linear(range, domain, uninterpolate, d3.interpolate);
    return scale;
  }

  function scale(x) {
    return output(x);
  }

  // Note: requires range is coercible to number!
  scale.invert = function(y) {
    return input(y);
  };

  scale.domain = function(x) {
    if (!arguments.length) return domain;
    domain = x.map(Number);
    return rescale();
  };

  scale.range = function(x) {
    if (!arguments.length) return range;
    range = x;
    return rescale();
  };

  scale.rangeRound = function(x) {
    return scale.range(x).interpolate(d3.interpolateRound);
  };

  scale.clamp = function(x) {
    if (!arguments.length) return clamp;
    clamp = x;
    return rescale();
  };

  scale.interpolate = function(x) {
    if (!arguments.length) return interpolate;
    interpolate = x;
    return rescale();
  };

  scale.ticks = function(m) {
    return d3_scale_linearTicks(domain, m);
  };

  scale.tickFormat = function(m) {
    return d3_scale_linearTickFormat(domain, m);
  };

  scale.nice = function() {
    d3_scale_nice(domain, d3_scale_linearNice);
    return rescale();
  };

  scale.copy = function() {
    return d3_scale_linear(domain, range, interpolate, clamp);
  };

  return rescale();
};

function d3_scale_linearRebind(scale, linear) {
  return d3.rebind(scale, linear, "range", "rangeRound", "interpolate", "clamp");
}

function d3_scale_linearNice(dx) {
  dx = Math.pow(10, Math.round(Math.log(dx) / Math.LN10) - 1);
  return {
    floor: function(x) { return Math.floor(x / dx) * dx; },
    ceil: function(x) { return Math.ceil(x / dx) * dx; }
  };
}

function d3_scale_linearTickRange(domain, m) {
  var extent = d3_scaleExtent(domain),
      span = extent[1] - extent[0],
      step = Math.pow(10, Math.floor(Math.log(span / m) / Math.LN10)),
      err = m / span * step;

  // Filter ticks to get closer to the desired count.
  if (err <= .15) step *= 10;
  else if (err <= .35) step *= 5;
  else if (err <= .75) step *= 2;

  // Round start and stop values to step interval.
  extent[0] = Math.ceil(extent[0] / step) * step;
  extent[1] = Math.floor(extent[1] / step) * step + step * .5; // inclusive
  extent[2] = step;
  return extent;
}

function d3_scale_linearTicks(domain, m) {
  return d3.range.apply(d3, d3_scale_linearTickRange(domain, m));
}

function d3_scale_linearTickFormat(domain, m) {
  return d3.format(",." + Math.max(0, -Math.floor(Math.log(d3_scale_linearTickRange(domain, m)[2]) / Math.LN10 + .01)) + "f");
}
function d3_scale_bilinear(domain, range, uninterpolate, interpolate) {
  var u = uninterpolate(domain[0], domain[1]),
      i = interpolate(range[0], range[1]);
  return function(x) {
    return i(u(x));
  };
}
function d3_scale_polylinear(domain, range, uninterpolate, interpolate) {
  var u = [],
      i = [],
      j = 0,
      k = domain.length - 1;

  // Handle descending domains.
  if (domain[k] < domain[0]) {
    domain = domain.slice().reverse();
    range = range.slice().reverse();
  }

  while (++j <= k) {
    u.push(uninterpolate(domain[j - 1], domain[j]));
    i.push(interpolate(range[j - 1], range[j]));
  }

  return function(x) {
    var j = d3.bisect(domain, x, 1, k) - 1;
    return i[j](u[j](x));
  };
}
d3.scale.log = function() {
  return d3_scale_log(d3.scale.linear(), d3_scale_logp);
};

function d3_scale_log(linear, log) {
  var pow = log.pow;

  function scale(x) {
    return linear(log(x));
  }

  scale.invert = function(x) {
    return pow(linear.invert(x));
  };

  scale.domain = function(x) {
    if (!arguments.length) return linear.domain().map(pow);
    log = x[0] < 0 ? d3_scale_logn : d3_scale_logp;
    pow = log.pow;
    linear.domain(x.map(log));
    return scale;
  };

  scale.nice = function() {
    linear.domain(d3_scale_nice(linear.domain(), d3_scale_niceDefault));
    return scale;
  };

  scale.ticks = function() {
    var extent = d3_scaleExtent(linear.domain()),
        ticks = [];
    if (extent.every(isFinite)) {
      var i = Math.floor(extent[0]),
          j = Math.ceil(extent[1]),
          u = pow(extent[0]),
          v = pow(extent[1]);
      if (log === d3_scale_logn) {
        ticks.push(pow(i));
        for (; i++ < j;) for (var k = 9; k > 0; k--) ticks.push(pow(i) * k);
      } else {
        for (; i < j; i++) for (var k = 1; k < 10; k++) ticks.push(pow(i) * k);
        ticks.push(pow(i));
      }
      for (i = 0; ticks[i] < u; i++) {} // strip small values
      for (j = ticks.length; ticks[j - 1] > v; j--) {} // strip big values
      ticks = ticks.slice(i, j);
    }
    return ticks;
  };

  scale.tickFormat = function(n, format) {
    if (arguments.length < 2) format = d3_scale_logFormat;
    if (arguments.length < 1) return format;
    var k = n / scale.ticks().length,
        f = log === d3_scale_logn ? (e = -1e-12, Math.floor) : (e = 1e-12, Math.ceil),
        e;
    return function(d) {
      return d / pow(f(log(d) + e)) < k ? format(d) : "";
    };
  };

  scale.copy = function() {
    return d3_scale_log(linear.copy(), log);
  };

  return d3_scale_linearRebind(scale, linear);
};

var d3_scale_logFormat = d3.format(".0e");

function d3_scale_logp(x) {
  return Math.log(x < 0 ? 0 : x) / Math.LN10;
}

function d3_scale_logn(x) {
  return -Math.log(x > 0 ? 0 : -x) / Math.LN10;
}

d3_scale_logp.pow = function(x) {
  return Math.pow(10, x);
};

d3_scale_logn.pow = function(x) {
  return -Math.pow(10, -x);
};
d3.scale.pow = function() {
  return d3_scale_pow(d3.scale.linear(), 1);
};

function d3_scale_pow(linear, exponent) {
  var powp = d3_scale_powPow(exponent),
      powb = d3_scale_powPow(1 / exponent);

  function scale(x) {
    return linear(powp(x));
  }

  scale.invert = function(x) {
    return powb(linear.invert(x));
  };

  scale.domain = function(x) {
    if (!arguments.length) return linear.domain().map(powb);
    linear.domain(x.map(powp));
    return scale;
  };

  scale.ticks = function(m) {
    return d3_scale_linearTicks(scale.domain(), m);
  };

  scale.tickFormat = function(m) {
    return d3_scale_linearTickFormat(scale.domain(), m);
  };

  scale.nice = function() {
    return scale.domain(d3_scale_nice(scale.domain(), d3_scale_linearNice));
  };

  scale.exponent = function(x) {
    if (!arguments.length) return exponent;
    var domain = scale.domain();
    powp = d3_scale_powPow(exponent = x);
    powb = d3_scale_powPow(1 / exponent);
    return scale.domain(domain);
  };

  scale.copy = function() {
    return d3_scale_pow(linear.copy(), exponent);
  };

  return d3_scale_linearRebind(scale, linear);
};

function d3_scale_powPow(e) {
  return function(x) {
    return x < 0 ? -Math.pow(-x, e) : Math.pow(x, e);
  };
}
d3.scale.sqrt = function() {
  return d3.scale.pow().exponent(.5);
};
d3.scale.ordinal = function() {
  return d3_scale_ordinal([], {t: "range", x: []});
};

function d3_scale_ordinal(domain, ranger) {
  var index,
      range,
      rangeBand;

  function scale(x) {
    return range[((index[x] || (index[x] = domain.push(x))) - 1) % range.length];
  }

  function steps(start, step) {
    return d3.range(domain.length).map(function(i) { return start + step * i; });
  }

  scale.domain = function(x) {
    if (!arguments.length) return domain;
    domain = [];
    index = {};
    var i = -1, n = x.length, xi;
    while (++i < n) if (!index[xi = x[i]]) index[xi] = domain.push(xi);
    return scale[ranger.t](ranger.x, ranger.p);
  };

  scale.range = function(x) {
    if (!arguments.length) return range;
    range = x;
    rangeBand = 0;
    ranger = {t: "range", x: x};
    return scale;
  };

  scale.rangePoints = function(x, padding) {
    if (arguments.length < 2) padding = 0;
    var start = x[0],
        stop = x[1],
        step = (stop - start) / (domain.length - 1 + padding);
    range = steps(domain.length < 2 ? (start + stop) / 2 : start + step * padding / 2, step);
    rangeBand = 0;
    ranger = {t: "rangePoints", x: x, p: padding};
    return scale;
  };

  scale.rangeBands = function(x, padding) {
    if (arguments.length < 2) padding = 0;
    var start = x[0],
        stop = x[1],
        step = (stop - start) / (domain.length + padding);
    range = steps(start + step * padding, step);
    rangeBand = step * (1 - padding);
    ranger = {t: "rangeBands", x: x, p: padding};
    return scale;
  };

  scale.rangeRoundBands = function(x, padding) {
    if (arguments.length < 2) padding = 0;
    var start = x[0],
        stop = x[1],
        step = Math.floor((stop - start) / (domain.length + padding));
    range = steps(start + Math.round((stop - start - (domain.length - padding) * step) / 2), step);
    rangeBand = Math.round(step * (1 - padding));
    ranger = {t: "rangeRoundBands", x: x, p: padding};
    return scale;
  };

  scale.rangeBand = function() {
    return rangeBand;
  };

  scale.rangeExtent = function() {
    return ranger.t === "range" ? d3_scaleExtent(ranger.x) : ranger.x;
  };

  scale.copy = function() {
    return d3_scale_ordinal(domain, ranger);
  };

  return scale.domain(domain);
};
/*
 * This product includes color specifications and designs developed by Cynthia
 * Brewer (http://colorbrewer.org/). See lib/colorbrewer for more information.
 */

d3.scale.category10 = function() {
  return d3.scale.ordinal().range(d3_category10);
};

d3.scale.category20 = function() {
  return d3.scale.ordinal().range(d3_category20);
};

d3.scale.category20b = function() {
  return d3.scale.ordinal().range(d3_category20b);
};

d3.scale.category20c = function() {
  return d3.scale.ordinal().range(d3_category20c);
};

var d3_category10 = [
  "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
  "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"
];

var d3_category20 = [
  "#1f77b4", "#aec7e8",
  "#ff7f0e", "#ffbb78",
  "#2ca02c", "#98df8a",
  "#d62728", "#ff9896",
  "#9467bd", "#c5b0d5",
  "#8c564b", "#c49c94",
  "#e377c2", "#f7b6d2",
  "#7f7f7f", "#c7c7c7",
  "#bcbd22", "#dbdb8d",
  "#17becf", "#9edae5"
];

var d3_category20b = [
  "#393b79", "#5254a3", "#6b6ecf", "#9c9ede",
  "#637939", "#8ca252", "#b5cf6b", "#cedb9c",
  "#8c6d31", "#bd9e39", "#e7ba52", "#e7cb94",
  "#843c39", "#ad494a", "#d6616b", "#e7969c",
  "#7b4173", "#a55194", "#ce6dbd", "#de9ed6"
];

var d3_category20c = [
  "#3182bd", "#6baed6", "#9ecae1", "#c6dbef",
  "#e6550d", "#fd8d3c", "#fdae6b", "#fdd0a2",
  "#31a354", "#74c476", "#a1d99b", "#c7e9c0",
  "#756bb1", "#9e9ac8", "#bcbddc", "#dadaeb",
  "#636363", "#969696", "#bdbdbd", "#d9d9d9"
];
d3.scale.quantile = function() {
  return d3_scale_quantile([], []);
};

function d3_scale_quantile(domain, range) {
  var thresholds;

  function rescale() {
    var k = 0,
        n = domain.length,
        q = range.length;
    thresholds = [];
    while (++k < q) thresholds[k - 1] = d3.quantile(domain, k / q);
    return scale;
  }

  function scale(x) {
    if (isNaN(x = +x)) return NaN;
    return range[d3.bisect(thresholds, x)];
  }

  scale.domain = function(x) {
    if (!arguments.length) return domain;
    domain = x.filter(function(d) { return !isNaN(d); }).sort(d3.ascending);
    return rescale();
  };

  scale.range = function(x) {
    if (!arguments.length) return range;
    range = x;
    return rescale();
  };

  scale.quantiles = function() {
    return thresholds;
  };

  scale.copy = function() {
    return d3_scale_quantile(domain, range); // copy on write!
  };

  return rescale();
};
d3.scale.quantize = function() {
  return d3_scale_quantize(0, 1, [0, 1]);
};

function d3_scale_quantize(x0, x1, range) {
  var kx, i;

  function scale(x) {
    return range[Math.max(0, Math.min(i, Math.floor(kx * (x - x0))))];
  }

  function rescale() {
    kx = range.length / (x1 - x0);
    i = range.length - 1;
    return scale;
  }

  scale.domain = function(x) {
    if (!arguments.length) return [x0, x1];
    x0 = +x[0];
    x1 = +x[x.length - 1];
    return rescale();
  };

  scale.range = function(x) {
    if (!arguments.length) return range;
    range = x;
    return rescale();
  };

  scale.copy = function() {
    return d3_scale_quantize(x0, x1, range); // copy on write
  };

  return rescale();
};
d3.svg = {};
d3.svg.arc = function() {
  var innerRadius = d3_svg_arcInnerRadius,
      outerRadius = d3_svg_arcOuterRadius,
      startAngle = d3_svg_arcStartAngle,
      endAngle = d3_svg_arcEndAngle;

  function arc() {
    var r0 = innerRadius.apply(this, arguments),
        r1 = outerRadius.apply(this, arguments),
        a0 = startAngle.apply(this, arguments) + d3_svg_arcOffset,
        a1 = endAngle.apply(this, arguments) + d3_svg_arcOffset,
        da = (a1 < a0 && (da = a0, a0 = a1, a1 = da), a1 - a0),
        df = da < Math.PI ? "0" : "1",
        c0 = Math.cos(a0),
        s0 = Math.sin(a0),
        c1 = Math.cos(a1),
        s1 = Math.sin(a1);
    return da >= d3_svg_arcMax
      ? (r0
      ? "M0," + r1
      + "A" + r1 + "," + r1 + " 0 1,1 0," + (-r1)
      + "A" + r1 + "," + r1 + " 0 1,1 0," + r1
      + "M0," + r0
      + "A" + r0 + "," + r0 + " 0 1,0 0," + (-r0)
      + "A" + r0 + "," + r0 + " 0 1,0 0," + r0
      + "Z"
      : "M0," + r1
      + "A" + r1 + "," + r1 + " 0 1,1 0," + (-r1)
      + "A" + r1 + "," + r1 + " 0 1,1 0," + r1
      + "Z")
      : (r0
      ? "M" + r1 * c0 + "," + r1 * s0
      + "A" + r1 + "," + r1 + " 0 " + df + ",1 " + r1 * c1 + "," + r1 * s1
      + "L" + r0 * c1 + "," + r0 * s1
      + "A" + r0 + "," + r0 + " 0 " + df + ",0 " + r0 * c0 + "," + r0 * s0
      + "Z"
      : "M" + r1 * c0 + "," + r1 * s0
      + "A" + r1 + "," + r1 + " 0 " + df + ",1 " + r1 * c1 + "," + r1 * s1
      + "L0,0"
      + "Z");
  }

  arc.innerRadius = function(v) {
    if (!arguments.length) return innerRadius;
    innerRadius = d3.functor(v);
    return arc;
  };

  arc.outerRadius = function(v) {
    if (!arguments.length) return outerRadius;
    outerRadius = d3.functor(v);
    return arc;
  };

  arc.startAngle = function(v) {
    if (!arguments.length) return startAngle;
    startAngle = d3.functor(v);
    return arc;
  };

  arc.endAngle = function(v) {
    if (!arguments.length) return endAngle;
    endAngle = d3.functor(v);
    return arc;
  };

  arc.centroid = function() {
    var r = (innerRadius.apply(this, arguments)
        + outerRadius.apply(this, arguments)) / 2,
        a = (startAngle.apply(this, arguments)
        + endAngle.apply(this, arguments)) / 2 + d3_svg_arcOffset;
    return [Math.cos(a) * r, Math.sin(a) * r];
  };

  return arc;
};

var d3_svg_arcOffset = -Math.PI / 2,
    d3_svg_arcMax = 2 * Math.PI - 1e-6;

function d3_svg_arcInnerRadius(d) {
  return d.innerRadius;
}

function d3_svg_arcOuterRadius(d) {
  return d.outerRadius;
}

function d3_svg_arcStartAngle(d) {
  return d.startAngle;
}

function d3_svg_arcEndAngle(d) {
  return d.endAngle;
}
function d3_svg_line(projection) {
  var x = d3_svg_lineX,
      y = d3_svg_lineY,
      interpolate = "linear",
      interpolator = d3_svg_lineInterpolators[interpolate],
      tension = .7;

  function line(d) {
    return d.length < 1 ? null : "M" + interpolator(projection(d3_svg_linePoints(this, d, x, y)), tension);
  }

  line.x = function(v) {
    if (!arguments.length) return x;
    x = v;
    return line;
  };

  line.y = function(v) {
    if (!arguments.length) return y;
    y = v;
    return line;
  };

  line.interpolate = function(v) {
    if (!arguments.length) return interpolate;
    interpolator = d3_svg_lineInterpolators[interpolate = v];
    return line;
  };

  line.tension = function(v) {
    if (!arguments.length) return tension;
    tension = v;
    return line;
  };

  return line;
}

d3.svg.line = function() {
  return d3_svg_line(Object);
};

// Converts the specified array of data into an array of points
// (x-y tuples), by evaluating the specified `x` and `y` functions on each
// data point. The `this` context of the evaluated functions is the specified
// "self" object; each function is passed the current datum and index.
function d3_svg_linePoints(self, d, x, y) {
  var points = [],
      i = -1,
      n = d.length,
      fx = typeof x === "function",
      fy = typeof y === "function",
      value;
  if (fx && fy) {
    while (++i < n) points.push([
      x.call(self, value = d[i], i),
      y.call(self, value, i)
    ]);
  } else if (fx) {
    while (++i < n) points.push([x.call(self, d[i], i), y]);
  } else if (fy) {
    while (++i < n) points.push([x, y.call(self, d[i], i)]);
  } else {
    while (++i < n) points.push([x, y]);
  }
  return points;
}

// The default `x` property, which references d[0].
function d3_svg_lineX(d) {
  return d[0];
}

// The default `y` property, which references d[1].
function d3_svg_lineY(d) {
  return d[1];
}

// The various interpolators supported by the `line` class.
var d3_svg_lineInterpolators = {
  "linear": d3_svg_lineLinear,
  "step-before": d3_svg_lineStepBefore,
  "step-after": d3_svg_lineStepAfter,
  "basis": d3_svg_lineBasis,
  "basis-open": d3_svg_lineBasisOpen,
  "basis-closed": d3_svg_lineBasisClosed,
  "bundle": d3_svg_lineBundle,
  "cardinal": d3_svg_lineCardinal,
  "cardinal-open": d3_svg_lineCardinalOpen,
  "cardinal-closed": d3_svg_lineCardinalClosed,
  "monotone": d3_svg_lineMonotone
};

// Linear interpolation; generates "L" commands.
function d3_svg_lineLinear(points) {
  var i = 0,
      n = points.length,
      p = points[0],
      path = [p[0], ",", p[1]];
  while (++i < n) path.push("L", (p = points[i])[0], ",", p[1]);
  return path.join("");
}

// Step interpolation; generates "H" and "V" commands.
function d3_svg_lineStepBefore(points) {
  var i = 0,
      n = points.length,
      p = points[0],
      path = [p[0], ",", p[1]];
  while (++i < n) path.push("V", (p = points[i])[1], "H", p[0]);
  return path.join("");
}

// Step interpolation; generates "H" and "V" commands.
function d3_svg_lineStepAfter(points) {
  var i = 0,
      n = points.length,
      p = points[0],
      path = [p[0], ",", p[1]];
  while (++i < n) path.push("H", (p = points[i])[0], "V", p[1]);
  return path.join("");
}

// Open cardinal spline interpolation; generates "C" commands.
function d3_svg_lineCardinalOpen(points, tension) {
  return points.length < 4
      ? d3_svg_lineLinear(points)
      : points[1] + d3_svg_lineHermite(points.slice(1, points.length - 1),
        d3_svg_lineCardinalTangents(points, tension));
}

// Closed cardinal spline interpolation; generates "C" commands.
function d3_svg_lineCardinalClosed(points, tension) {
  return points.length < 3
      ? d3_svg_lineLinear(points)
      : points[0] + d3_svg_lineHermite((points.push(points[0]), points),
        d3_svg_lineCardinalTangents([points[points.length - 2]]
        .concat(points, [points[1]]), tension));
}

// Cardinal spline interpolation; generates "C" commands.
function d3_svg_lineCardinal(points, tension, closed) {
  return points.length < 3
      ? d3_svg_lineLinear(points)
      : points[0] + d3_svg_lineHermite(points,
        d3_svg_lineCardinalTangents(points, tension));
}

// Hermite spline construction; generates "C" commands.
function d3_svg_lineHermite(points, tangents) {
  if (tangents.length < 1
      || (points.length != tangents.length
      && points.length != tangents.length + 2)) {
    return d3_svg_lineLinear(points);
  }

  var quad = points.length != tangents.length,
      path = "",
      p0 = points[0],
      p = points[1],
      t0 = tangents[0],
      t = t0,
      pi = 1;

  if (quad) {
    path += "Q" + (p[0] - t0[0] * 2 / 3) + "," + (p[1] - t0[1] * 2 / 3)
        + "," + p[0] + "," + p[1];
    p0 = points[1];
    pi = 2;
  }

  if (tangents.length > 1) {
    t = tangents[1];
    p = points[pi];
    pi++;
    path += "C" + (p0[0] + t0[0]) + "," + (p0[1] + t0[1])
        + "," + (p[0] - t[0]) + "," + (p[1] - t[1])
        + "," + p[0] + "," + p[1];
    for (var i = 2; i < tangents.length; i++, pi++) {
      p = points[pi];
      t = tangents[i];
      path += "S" + (p[0] - t[0]) + "," + (p[1] - t[1])
          + "," + p[0] + "," + p[1];
    }
  }

  if (quad) {
    var lp = points[pi];
    path += "Q" + (p[0] + t[0] * 2 / 3) + "," + (p[1] + t[1] * 2 / 3)
        + "," + lp[0] + "," + lp[1];
  }

  return path;
}

// Generates tangents for a cardinal spline.
function d3_svg_lineCardinalTangents(points, tension) {
  var tangents = [],
      a = (1 - tension) / 2,
      p0,
      p1 = points[0],
      p2 = points[1],
      i = 1,
      n = points.length;
  while (++i < n) {
    p0 = p1;
    p1 = p2;
    p2 = points[i];
    tangents.push([a * (p2[0] - p0[0]), a * (p2[1] - p0[1])]);
  }
  return tangents;
}

// B-spline interpolation; generates "C" commands.
function d3_svg_lineBasis(points) {
  if (points.length < 3) return d3_svg_lineLinear(points);
  var i = 1,
      n = points.length,
      pi = points[0],
      x0 = pi[0],
      y0 = pi[1],
      px = [x0, x0, x0, (pi = points[1])[0]],
      py = [y0, y0, y0, pi[1]],
      path = [x0, ",", y0];
  d3_svg_lineBasisBezier(path, px, py);
  while (++i < n) {
    pi = points[i];
    px.shift(); px.push(pi[0]);
    py.shift(); py.push(pi[1]);
    d3_svg_lineBasisBezier(path, px, py);
  }
  i = -1;
  while (++i < 2) {
    px.shift(); px.push(pi[0]);
    py.shift(); py.push(pi[1]);
    d3_svg_lineBasisBezier(path, px, py);
  }
  return path.join("");
}

// Open B-spline interpolation; generates "C" commands.
function d3_svg_lineBasisOpen(points) {
  if (points.length < 4) return d3_svg_lineLinear(points);
  var path = [],
      i = -1,
      n = points.length,
      pi,
      px = [0],
      py = [0];
  while (++i < 3) {
    pi = points[i];
    px.push(pi[0]);
    py.push(pi[1]);
  }
  path.push(d3_svg_lineDot4(d3_svg_lineBasisBezier3, px)
    + "," + d3_svg_lineDot4(d3_svg_lineBasisBezier3, py));
  --i; while (++i < n) {
    pi = points[i];
    px.shift(); px.push(pi[0]);
    py.shift(); py.push(pi[1]);
    d3_svg_lineBasisBezier(path, px, py);
  }
  return path.join("");
}

// Closed B-spline interpolation; generates "C" commands.
function d3_svg_lineBasisClosed(points) {
  var path,
      i = -1,
      n = points.length,
      m = n + 4,
      pi,
      px = [],
      py = [];
  while (++i < 4) {
    pi = points[i % n];
    px.push(pi[0]);
    py.push(pi[1]);
  }
  path = [
    d3_svg_lineDot4(d3_svg_lineBasisBezier3, px), ",",
    d3_svg_lineDot4(d3_svg_lineBasisBezier3, py)
  ];
  --i; while (++i < m) {
    pi = points[i % n];
    px.shift(); px.push(pi[0]);
    py.shift(); py.push(pi[1]);
    d3_svg_lineBasisBezier(path, px, py);
  }
  return path.join("");
}

function d3_svg_lineBundle(points, tension) {
  var n = points.length - 1,
      x0 = points[0][0],
      y0 = points[0][1],
      dx = points[n][0] - x0,
      dy = points[n][1] - y0,
      i = -1,
      p,
      t;
  while (++i <= n) {
    p = points[i];
    t = i / n;
    p[0] = tension * p[0] + (1 - tension) * (x0 + t * dx);
    p[1] = tension * p[1] + (1 - tension) * (y0 + t * dy);
  }
  return d3_svg_lineBasis(points);
}

// Returns the dot product of the given four-element vectors.
function d3_svg_lineDot4(a, b) {
  return a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3];
}

// Matrix to transform basis (b-spline) control points to bezier
// control points. Derived from FvD 11.2.8.
var d3_svg_lineBasisBezier1 = [0, 2/3, 1/3, 0],
    d3_svg_lineBasisBezier2 = [0, 1/3, 2/3, 0],
    d3_svg_lineBasisBezier3 = [0, 1/6, 2/3, 1/6];

// Pushes a "C" Bézier curve onto the specified path array, given the
// two specified four-element arrays which define the control points.
function d3_svg_lineBasisBezier(path, x, y) {
  path.push(
      "C", d3_svg_lineDot4(d3_svg_lineBasisBezier1, x),
      ",", d3_svg_lineDot4(d3_svg_lineBasisBezier1, y),
      ",", d3_svg_lineDot4(d3_svg_lineBasisBezier2, x),
      ",", d3_svg_lineDot4(d3_svg_lineBasisBezier2, y),
      ",", d3_svg_lineDot4(d3_svg_lineBasisBezier3, x),
      ",", d3_svg_lineDot4(d3_svg_lineBasisBezier3, y));
}

// Computes the slope from points p0 to p1.
function d3_svg_lineSlope(p0, p1) {
  return (p1[1] - p0[1]) / (p1[0] - p0[0]);
}

// Compute three-point differences for the given points.
// http://en.wikipedia.org/wiki/Cubic_Hermite_spline#Finite_difference
function d3_svg_lineFiniteDifferences(points) {
  var i = 0,
      j = points.length - 1,
      m = [],
      p0 = points[0],
      p1 = points[1],
      d = m[0] = d3_svg_lineSlope(p0, p1);
  while (++i < j) {
    m[i] = d + (d = d3_svg_lineSlope(p0 = p1, p1 = points[i + 1]));
  }
  m[i] = d;
  return m;
}

// Interpolates the given points using Fritsch-Carlson Monotone cubic Hermite
// interpolation. Returns an array of tangent vectors. For details, see
// http://en.wikipedia.org/wiki/Monotone_cubic_interpolation
function d3_svg_lineMonotoneTangents(points) {
  var tangents = [],
      d,
      a,
      b,
      s,
      m = d3_svg_lineFiniteDifferences(points),
      i = -1,
      j = points.length - 1;

  // The first two steps are done by computing finite-differences:
  // 1. Compute the slopes of the secant lines between successive points.
  // 2. Initialize the tangents at every point as the average of the secants.

  // Then, for each segment…
  while (++i < j) {
    d = d3_svg_lineSlope(points[i], points[i + 1]);

    // 3. If two successive yk = y{k + 1} are equal (i.e., d is zero), then set
    // mk = m{k + 1} = 0 as the spline connecting these points must be flat to
    // preserve monotonicity. Ignore step 4 and 5 for those k.

    if (Math.abs(d) < 1e-6) {
      m[i] = m[i + 1] = 0;
    } else {
      // 4. Let ak = mk / dk and bk = m{k + 1} / dk.
      a = m[i] / d;
      b = m[i + 1] / d;

      // 5. Prevent overshoot and ensure monotonicity by restricting the
      // magnitude of vector <ak, bk> to a circle of radius 3.
      s = a * a + b * b;
      if (s > 9) {
        s = d * 3 / Math.sqrt(s);
        m[i] = s * a;
        m[i + 1] = s * b;
      }
    }
  }

  // Compute the normalized tangent vector from the slopes. Note that if x is
  // not monotonic, it's possible that the slope will be infinite, so we protect
  // against NaN by setting the coordinate to zero.
  i = -1; while (++i <= j) {
    s = (points[Math.min(j, i + 1)][0] - points[Math.max(0, i - 1)][0])
      / (6 * (1 + m[i] * m[i]));
    tangents.push([s || 0, m[i] * s || 0]);
  }

  return tangents;
}

function d3_svg_lineMonotone(points) {
  return points.length < 3
      ? d3_svg_lineLinear(points)
      : points[0] +
        d3_svg_lineHermite(points, d3_svg_lineMonotoneTangents(points));
}
d3.svg.line.radial = function() {
  var line = d3_svg_line(d3_svg_lineRadial);
  line.radius = line.x, delete line.x;
  line.angle = line.y, delete line.y;
  return line;
};

function d3_svg_lineRadial(points) {
  var point,
      i = -1,
      n = points.length,
      r,
      a;
  while (++i < n) {
    point = points[i];
    r = point[0];
    a = point[1] + d3_svg_arcOffset;
    point[0] = r * Math.cos(a);
    point[1] = r * Math.sin(a);
  }
  return points;
}
function d3_svg_area(projection) {
  var x0 = d3_svg_lineX,
      x1 = d3_svg_lineX,
      y0 = 0,
      y1 = d3_svg_lineY,
      interpolate,
      i0,
      i1,
      tension = .7;

  function area(d) {
    if (d.length < 1) return null;
    var points0 = d3_svg_linePoints(this, d, x0, y0),
        points1 = d3_svg_linePoints(this, d, x0 === x1 ? d3_svg_areaX(points0) : x1, y0 === y1 ? d3_svg_areaY(points0) : y1);
    return "M" + i0(projection(points1), tension)
         + "L" + i1(projection(points0.reverse()), tension)
         + "Z";
  }

  area.x = function(x) {
    if (!arguments.length) return x1;
    x0 = x1 = x;
    return area;
  };

  area.x0 = function(x) {
    if (!arguments.length) return x0;
    x0 = x;
    return area;
  };

  area.x1 = function(x) {
    if (!arguments.length) return x1;
    x1 = x;
    return area;
  };

  area.y = function(y) {
    if (!arguments.length) return y1;
    y0 = y1 = y;
    return area;
  };

  area.y0 = function(y) {
    if (!arguments.length) return y0;
    y0 = y;
    return area;
  };

  area.y1 = function(y) {
    if (!arguments.length) return y1;
    y1 = y;
    return area;
  };

  area.interpolate = function(x) {
    if (!arguments.length) return interpolate;
    i0 = d3_svg_lineInterpolators[interpolate = x];
    i1 = i0.reverse || i0;
    return area;
  };

  area.tension = function(x) {
    if (!arguments.length) return tension;
    tension = x;
    return area;
  };

  return area.interpolate("linear");
}

d3_svg_lineStepBefore.reverse = d3_svg_lineStepAfter;
d3_svg_lineStepAfter.reverse = d3_svg_lineStepBefore;

d3.svg.area = function() {
  return d3_svg_area(Object);
};

function d3_svg_areaX(points) {
  return function(d, i) {
    return points[i][0];
  };
}

function d3_svg_areaY(points) {
  return function(d, i) {
    return points[i][1];
  };
}
d3.svg.area.radial = function() {
  var area = d3_svg_area(d3_svg_lineRadial);
  area.radius = area.x, delete area.x;
  area.innerRadius = area.x0, delete area.x0;
  area.outerRadius = area.x1, delete area.x1;
  area.angle = area.y, delete area.y;
  area.startAngle = area.y0, delete area.y0;
  area.endAngle = area.y1, delete area.y1;
  return area;
};
d3.svg.chord = function() {
  var source = d3_svg_chordSource,
      target = d3_svg_chordTarget,
      radius = d3_svg_chordRadius,
      startAngle = d3_svg_arcStartAngle,
      endAngle = d3_svg_arcEndAngle;

  // TODO Allow control point to be customized.

  function chord(d, i) {
    var s = subgroup(this, source, d, i),
        t = subgroup(this, target, d, i);
    return "M" + s.p0
      + arc(s.r, s.p1, s.a1 - s.a0) + (equals(s, t)
      ? curve(s.r, s.p1, s.r, s.p0)
      : curve(s.r, s.p1, t.r, t.p0)
      + arc(t.r, t.p1, t.a1 - t.a0)
      + curve(t.r, t.p1, s.r, s.p0))
      + "Z";
  }

  function subgroup(self, f, d, i) {
    var subgroup = f.call(self, d, i),
        r = radius.call(self, subgroup, i),
        a0 = startAngle.call(self, subgroup, i) + d3_svg_arcOffset,
        a1 = endAngle.call(self, subgroup, i) + d3_svg_arcOffset;
    return {
      r: r,
      a0: a0,
      a1: a1,
      p0: [r * Math.cos(a0), r * Math.sin(a0)],
      p1: [r * Math.cos(a1), r * Math.sin(a1)]
    };
  }

  function equals(a, b) {
    return a.a0 == b.a0 && a.a1 == b.a1;
  }

  function arc(r, p, a) {
    return "A" + r + "," + r + " 0 " + +(a > Math.PI) + ",1 " + p;
  }

  function curve(r0, p0, r1, p1) {
    return "Q 0,0 " + p1;
  }

  chord.radius = function(v) {
    if (!arguments.length) return radius;
    radius = d3.functor(v);
    return chord;
  };

  chord.source = function(v) {
    if (!arguments.length) return source;
    source = d3.functor(v);
    return chord;
  };

  chord.target = function(v) {
    if (!arguments.length) return target;
    target = d3.functor(v);
    return chord;
  };

  chord.startAngle = function(v) {
    if (!arguments.length) return startAngle;
    startAngle = d3.functor(v);
    return chord;
  };

  chord.endAngle = function(v) {
    if (!arguments.length) return endAngle;
    endAngle = d3.functor(v);
    return chord;
  };

  return chord;
};

function d3_svg_chordSource(d) {
  return d.source;
}

function d3_svg_chordTarget(d) {
  return d.target;
}

function d3_svg_chordRadius(d) {
  return d.radius;
}

function d3_svg_chordStartAngle(d) {
  return d.startAngle;
}

function d3_svg_chordEndAngle(d) {
  return d.endAngle;
}
d3.svg.diagonal = function() {
  var source = d3_svg_chordSource,
      target = d3_svg_chordTarget,
      projection = d3_svg_diagonalProjection;

  function diagonal(d, i) {
    var p0 = source.call(this, d, i),
        p3 = target.call(this, d, i),
        m = (p0.y + p3.y) / 2,
        p = [p0, {x: p0.x, y: m}, {x: p3.x, y: m}, p3];
    p = p.map(projection);
    return "M" + p[0] + "C" + p[1] + " " + p[2] + " " + p[3];
  }

  diagonal.source = function(x) {
    if (!arguments.length) return source;
    source = d3.functor(x);
    return diagonal;
  };

  diagonal.target = function(x) {
    if (!arguments.length) return target;
    target = d3.functor(x);
    return diagonal;
  };

  diagonal.projection = function(x) {
    if (!arguments.length) return projection;
    projection = x;
    return diagonal;
  };

  return diagonal;
};

function d3_svg_diagonalProjection(d) {
  return [d.x, d.y];
}
d3.svg.diagonal.radial = function() {
  var diagonal = d3.svg.diagonal(),
      projection = d3_svg_diagonalProjection,
      projection_ = diagonal.projection;

  diagonal.projection = function(x) {
    return arguments.length
        ? projection_(d3_svg_diagonalRadialProjection(projection = x))
        : projection;
  };

  return diagonal;
};

function d3_svg_diagonalRadialProjection(projection) {
  return function() {
    var d = projection.apply(this, arguments),
        r = d[0],
        a = d[1] + d3_svg_arcOffset;
    return [r * Math.cos(a), r * Math.sin(a)];
  };
}
d3.svg.mouse = function(container) {
  return d3_svg_mousePoint(container, d3.event);
};

// https://bugs.webkit.org/show_bug.cgi?id=44083
var d3_mouse_bug44083 = /WebKit/.test(navigator.userAgent) ? -1 : 0;

function d3_svg_mousePoint(container, e) {
  var point = (container.ownerSVGElement || container).createSVGPoint();
  if ((d3_mouse_bug44083 < 0) && (window.scrollX || window.scrollY)) {
    var svg = d3.select(document.body)
      .append("svg")
        .style("position", "absolute")
        .style("top", 0)
        .style("left", 0);
    var ctm = svg[0][0].getScreenCTM();
    d3_mouse_bug44083 = !(ctm.f || ctm.e);
    svg.remove();
  }
  if (d3_mouse_bug44083) {
    point.x = e.pageX;
    point.y = e.pageY;
  } else {
    point.x = e.clientX;
    point.y = e.clientY;
  }
  point = point.matrixTransform(container.getScreenCTM().inverse());
  return [point.x, point.y];
};
d3.svg.touches = function(container, touches) {
  if (arguments.length < 2) touches = d3.event.touches;

  return touches ? d3_array(touches).map(function(touch) {
    var point = d3_svg_mousePoint(container, touch);
    point.identifier = touch.identifier;
    return point;
  }) : [];
};
d3.svg.symbol = function() {
  var type = d3_svg_symbolType,
      size = d3_svg_symbolSize;

  function symbol(d, i) {
    return (d3_svg_symbols[type.call(this, d, i)]
        || d3_svg_symbols.circle)
        (size.call(this, d, i));
  }

  symbol.type = function(x) {
    if (!arguments.length) return type;
    type = d3.functor(x);
    return symbol;
  };

  // size of symbol in square pixels
  symbol.size = function(x) {
    if (!arguments.length) return size;
    size = d3.functor(x);
    return symbol;
  };

  return symbol;
};

function d3_svg_symbolSize() {
  return 64;
}

function d3_svg_symbolType() {
  return "circle";
}

// TODO cross-diagonal?
var d3_svg_symbols = {
  "circle": function(size) {
    var r = Math.sqrt(size / Math.PI);
    return "M0," + r
        + "A" + r + "," + r + " 0 1,1 0," + (-r)
        + "A" + r + "," + r + " 0 1,1 0," + r
        + "Z";
  },
  "cross": function(size) {
    var r = Math.sqrt(size / 5) / 2;
    return "M" + -3 * r + "," + -r
        + "H" + -r
        + "V" + -3 * r
        + "H" + r
        + "V" + -r
        + "H" + 3 * r
        + "V" + r
        + "H" + r
        + "V" + 3 * r
        + "H" + -r
        + "V" + r
        + "H" + -3 * r
        + "Z";
  },
  "diamond": function(size) {
    var ry = Math.sqrt(size / (2 * d3_svg_symbolTan30)),
        rx = ry * d3_svg_symbolTan30;
    return "M0," + -ry
        + "L" + rx + ",0"
        + " 0," + ry
        + " " + -rx + ",0"
        + "Z";
  },
  "square": function(size) {
    var r = Math.sqrt(size) / 2;
    return "M" + -r + "," + -r
        + "L" + r + "," + -r
        + " " + r + "," + r
        + " " + -r + "," + r
        + "Z";
  },
  "triangle-down": function(size) {
    var rx = Math.sqrt(size / d3_svg_symbolSqrt3),
        ry = rx * d3_svg_symbolSqrt3 / 2;
    return "M0," + ry
        + "L" + rx +"," + -ry
        + " " + -rx + "," + -ry
        + "Z";
  },
  "triangle-up": function(size) {
    var rx = Math.sqrt(size / d3_svg_symbolSqrt3),
        ry = rx * d3_svg_symbolSqrt3 / 2;
    return "M0," + -ry
        + "L" + rx +"," + ry
        + " " + -rx + "," + ry
        + "Z";
  }
};

d3.svg.symbolTypes = d3.keys(d3_svg_symbols);

var d3_svg_symbolSqrt3 = Math.sqrt(3),
    d3_svg_symbolTan30 = Math.tan(30 * Math.PI / 180);
d3.svg.axis = function() {
  var scale = d3.scale.linear(),
      orient = "bottom",
      tickMajorSize = 6,
      tickMinorSize = 6,
      tickEndSize = 6,
      tickPadding = 3,
      tickArguments_ = [10],
      tickFormat_,
      tickSubdivide = 0;

  function axis(selection) {
    selection.each(function(d, i, j) {
      var g = d3.select(this);

      // If selection is a transition, create subtransitions.
      var transition = selection.delay ? function(o) {
        var id = d3_transitionInheritId;
        try {
          d3_transitionInheritId = selection.id;
          return o.transition()
              .delay(selection[j][i].delay)
              .duration(selection[j][i].duration)
              .ease(selection.ease());
        } finally {
          d3_transitionInheritId = id;
        }
      } : Object;

      // Ticks, or domain values for ordinal scales.
      var ticks = scale.ticks ? scale.ticks.apply(scale, tickArguments_) : scale.domain(),
          tickFormat = tickFormat_ == null ? (scale.tickFormat ? scale.tickFormat.apply(scale, tickArguments_) : String) : tickFormat_;

      // Minor ticks.
      var subticks = d3_svg_axisSubdivide(scale, ticks, tickSubdivide),
          subtick = g.selectAll(".minor").data(subticks, String),
          subtickEnter = subtick.enter().insert("line", "g").attr("class", "tick minor").style("opacity", 1e-6),
          subtickExit = transition(subtick.exit()).style("opacity", 1e-6).remove(),
          subtickUpdate = transition(subtick).style("opacity", 1);

      // Major ticks.
      var tick = g.selectAll("g").data(ticks, String),
          tickEnter = tick.enter().insert("g", "path").style("opacity", 1e-6),
          tickExit = transition(tick.exit()).style("opacity", 1e-6).remove(),
          tickUpdate = transition(tick).style("opacity", 1),
          tickTransform;

      // Domain.
      var range = d3_scaleRange(scale),
          path = g.selectAll(".domain").data([0]),
          pathEnter = path.enter().append("path").attr("class", "domain"),
          pathUpdate = transition(path);

      // Stash a snapshot of the new scale, and retrieve the old snapshot.
      var scale1 = scale.copy(),
          scale0 = this.__chart__ || scale1;
      this.__chart__ = scale1;

      tickEnter.append("line").attr("class", "tick");
      tickEnter.append("text");
      tickUpdate.select("text").text(tickFormat);

      switch (orient) {
        case "bottom": {
          tickTransform = d3_svg_axisX;
          subtickEnter.attr("y2", tickMinorSize);
          subtickUpdate.attr("x2", 0).attr("y2", tickMinorSize);
          tickEnter.select("line").attr("y2", tickMajorSize);
          tickEnter.select("text").attr("y", Math.max(tickMajorSize, 0) + tickPadding);
          tickUpdate.select("line").attr("x2", 0).attr("y2", tickMajorSize);
          tickUpdate.select("text").attr("x", 0).attr("y", Math.max(tickMajorSize, 0) + tickPadding).attr("dy", ".71em").attr("text-anchor", "middle");
          pathUpdate.attr("d", "M" + range[0] + "," + tickEndSize + "V0H" + range[1] + "V" + tickEndSize);
          break;
        }
        case "top": {
          tickTransform = d3_svg_axisX;
          subtickEnter.attr("y2", -tickMinorSize);
          subtickUpdate.attr("x2", 0).attr("y2", -tickMinorSize);
          tickEnter.select("line").attr("y2", -tickMajorSize);
          tickEnter.select("text").attr("y", -(Math.max(tickMajorSize, 0) + tickPadding));
          tickUpdate.select("line").attr("x2", 0).attr("y2", -tickMajorSize);
          tickUpdate.select("text").attr("x", 0).attr("y", -(Math.max(tickMajorSize, 0) + tickPadding)).attr("dy", "0em").attr("text-anchor", "middle");
          pathUpdate.attr("d", "M" + range[0] + "," + -tickEndSize + "V0H" + range[1] + "V" + -tickEndSize);
          break;
        }
        case "left": {
          tickTransform = d3_svg_axisY;
          subtickEnter.attr("x2", -tickMinorSize);
          subtickUpdate.attr("x2", -tickMinorSize).attr("y2", 0);
          tickEnter.select("line").attr("x2", -tickMajorSize);
          tickEnter.select("text").attr("x", -(Math.max(tickMajorSize, 0) + tickPadding));
          tickUpdate.select("line").attr("x2", -tickMajorSize).attr("y2", 0);
          tickUpdate.select("text").attr("x", -(Math.max(tickMajorSize, 0) + tickPadding)).attr("y", 0).attr("dy", ".32em").attr("text-anchor", "end");
          pathUpdate.attr("d", "M" + -tickEndSize + "," + range[0] + "H0V" + range[1] + "H" + -tickEndSize);
          break;
        }
        case "right": {
          tickTransform = d3_svg_axisY;
          subtickEnter.attr("x2", tickMinorSize);
          subtickUpdate.attr("x2", tickMinorSize).attr("y2", 0);
          tickEnter.select("line").attr("x2", tickMajorSize);
          tickEnter.select("text").attr("x", Math.max(tickMajorSize, 0) + tickPadding);
          tickUpdate.select("line").attr("x2", tickMajorSize).attr("y2", 0);
          tickUpdate.select("text").attr("x", Math.max(tickMajorSize, 0) + tickPadding).attr("y", 0).attr("dy", ".32em").attr("text-anchor", "start");
          pathUpdate.attr("d", "M" + tickEndSize + "," + range[0] + "H0V" + range[1] + "H" + tickEndSize);
          break;
        }
      }

      // For quantitative scales:
      // - enter new ticks from the old scale
      // - exit old ticks to the new scale
      if (scale.ticks) {
        tickEnter.call(tickTransform, scale0);
        tickUpdate.call(tickTransform, scale1);
        tickExit.call(tickTransform, scale1);
        subtickEnter.call(tickTransform, scale0);
        subtickUpdate.call(tickTransform, scale1);
        subtickExit.call(tickTransform, scale1);
      }

      // For ordinal scales:
      // - any entering ticks are undefined in the old scale
      // - any exiting ticks are undefined in the new scale
      // Therefore, we only need to transition updating ticks.
      else {
        var dx = scale1.rangeBand() / 2, x = function(d) { return scale1(d) + dx; };
        tickEnter.call(tickTransform, x);
        tickUpdate.call(tickTransform, x);
      }
    });
  }

  axis.scale = function(x) {
    if (!arguments.length) return scale;
    scale = x;
    return axis;
  };

  axis.orient = function(x) {
    if (!arguments.length) return orient;
    orient = x;
    return axis;
  };

  axis.ticks = function() {
    if (!arguments.length) return tickArguments_;
    tickArguments_ = arguments;
    return axis;
  };

  axis.tickFormat = function(x) {
    if (!arguments.length) return tickFormat_;
    tickFormat_ = x;
    return axis;
  };

  axis.tickSize = function(x, y, z) {
    if (!arguments.length) return tickMajorSize;
    var n = arguments.length - 1;
    tickMajorSize = +x;
    tickMinorSize = n > 1 ? +y : tickMajorSize;
    tickEndSize = n > 0 ? +arguments[n] : tickMajorSize;
    return axis;
  };

  axis.tickPadding = function(x) {
    if (!arguments.length) return tickPadding;
    tickPadding = +x;
    return axis;
  };

  axis.tickSubdivide = function(x) {
    if (!arguments.length) return tickSubdivide;
    tickSubdivide = +x;
    return axis;
  };

  return axis;
};

function d3_svg_axisX(selection, x) {
  selection.attr("transform", function(d) { return "translate(" + x(d) + ",0)"; });
}

function d3_svg_axisY(selection, y) {
  selection.attr("transform", function(d) { return "translate(0," + y(d) + ")"; });
}

function d3_svg_axisSubdivide(scale, ticks, m) {
  subticks = [];
  if (m && ticks.length > 1) {
    var extent = d3_scaleExtent(scale.domain()),
        subticks,
        i = -1,
        n = ticks.length,
        d = (ticks[1] - ticks[0]) / ++m,
        j,
        v;
    while (++i < n) {
      for (j = m; --j > 0;) {
        if ((v = +ticks[i] - j * d) >= extent[0]) {
          subticks.push(v);
        }
      }
    }
    for (--i, j = 0; ++j < m && (v = +ticks[i] + j * d) < extent[1];) {
      subticks.push(v);
    }
  }
  return subticks;
}
d3.svg.brush = function() {
  var event = d3.dispatch("brushstart", "brush", "brushend"),
      x, // x-scale, optional
      y, // y-scale, optional
      extent = [[0, 0], [0, 0]]; // [x0, y0], [x1, y1]

  function brush(g) {
    var resizes = x && y ? ["n", "e", "s", "w", "nw", "ne", "se", "sw"]
        : x ? ["e", "w"]
        : y ? ["n", "s"]
        : [];

    g.each(function() {
      var g = d3.select(this).on("mousedown.brush", down),
          bg = g.selectAll(".background").data([0]),
          fg = g.selectAll(".extent").data([0]),
          tz = g.selectAll(".resize").data(resizes, String),
          e;

      // An invisible, mouseable area for starting a new brush.
      bg.enter().append("rect")
          .attr("class", "background")
          .style("visibility", "hidden")
          .style("pointer-events", "all")
          .style("cursor", "crosshair");

      // The visible brush extent; style this as you like!
      fg.enter().append("rect")
          .attr("class", "extent")
          .style("cursor", "move");

      // More invisible rects for resizing the extent.
      tz.enter().append("rect")
          .attr("class", function(d) { return "resize " + d; })
          .attr("width", 6)
          .attr("height", 6)
          .style("visibility", "hidden")
          .style("cursor", function(d) { return d3_svg_brushCursor[d]; });

      // Update the resizers.
      tz.style("pointer-events", brush.empty() ? "none" : "all");

      // Remove any superfluous resizers.
      tz.exit().remove();

      // Initialize the background to fill the defined range.
      // If the range isn't defined, you can post-process.
      if (x) {
        e = d3_scaleRange(x);
        bg.attr("x", e[0]).attr("width", e[1] - e[0]);
        d3_svg_brushRedrawX(g, extent);
      }
      if (y) {
        e = d3_scaleRange(y);
        bg.attr("y", e[0]).attr("height", e[1] - e[0]);
        d3_svg_brushRedrawY(g, extent);
      }
    });
  }

  function down() {
    var target = d3.select(d3.event.target);

    // Store some global state for the duration of the brush gesture.
    d3_svg_brush = brush;
    d3_svg_brushTarget = this;
    d3_svg_brushExtent = extent;
    d3_svg_brushOffset = d3.svg.mouse(d3_svg_brushTarget);

    // If the extent was clicked on, drag rather than brush;
    // store the offset between the mouse and extent origin instead.
    if (d3_svg_brushDrag = target.classed("extent")) {
      d3_svg_brushOffset[0] = extent[0][0] - d3_svg_brushOffset[0];
      d3_svg_brushOffset[1] = extent[0][1] - d3_svg_brushOffset[1];
    }

    // If a resizer was clicked on, record which side is to be resized.
    // Also, set the offset to the opposite side.
    else if (target.classed("resize")) {
      d3_svg_brushResize = d3.event.target.__data__;
      d3_svg_brushOffset[0] = extent[+/w$/.test(d3_svg_brushResize)][0];
      d3_svg_brushOffset[1] = extent[+/^n/.test(d3_svg_brushResize)][1];
    }

    // If the ALT key is down when starting a brush, the center is at the mouse.
    else if (d3.event.altKey) {
      d3_svg_brushCenter = d3_svg_brushOffset.slice();
    }

    // Restrict which dimensions are resized.
    d3_svg_brushX = !/^(n|s)$/.test(d3_svg_brushResize) && x;
    d3_svg_brushY = !/^(e|w)$/.test(d3_svg_brushResize) && y;

    // Notify listeners.
    d3_svg_brushDispatch = dispatcher(this, arguments);
    d3_svg_brushDispatch("brushstart");
    d3_svg_brushMove();
    d3_eventCancel();
  }

  function dispatcher(that, argumentz) {
    return function(type) {
      var e = d3.event;
      try {
        d3.event = {type: type, target: brush};
        event[type].apply(that, argumentz);
      } finally {
        d3.event = e;
      }
    };
  }

  brush.x = function(z) {
    if (!arguments.length) return x;
    x = z;
    return brush;
  };

  brush.y = function(z) {
    if (!arguments.length) return y;
    y = z;
    return brush;
  };

  brush.extent = function(z) {
    var x0, x1, y0, y1, t;

    // Invert the pixel extent to data-space.
    if (!arguments.length) {
      if (x) {
        x0 = extent[0][0], x1 = extent[1][0];
        if (x.invert) x0 = x.invert(x0), x1 = x.invert(x1);
        if (x1 < x0) t = x0, x0 = x1, x1 = t;
      }
      if (y) {
        y0 = extent[0][1], y1 = extent[1][1];
        if (y.invert) y0 = y.invert(y0), y1 = y.invert(y1);
        if (y1 < y0) t = y0, y0 = y1, y1 = t;
      }
      return x && y ? [[x0, y0], [x1, y1]] : x ? [x0, x1] : y && [y0, y1];
    }

    // Scale the data-space extent to pixels.
    if (x) {
      x0 = z[0], x1 = z[1];
      if (y) x0 = x0[0], x1 = x1[0];
      if (x.invert) x0 = x(x0), x1 = x(x1);
      if (x1 < x0) t = x0, x0 = x1, x1 = t;
      extent[0][0] = x0, extent[1][0] = x1;
    }
    if (y) {
      y0 = z[0], y1 = z[1];
      if (x) y0 = y0[1], y1 = y1[1];
      if (y.invert) y0 = y(y0), y1 = y(y1);
      if (y1 < y0) t = y0, y0 = y1, y1 = t;
      extent[0][1] = y0, extent[1][1] = y1;
    }

    return brush;
  };

  brush.clear = function() {
    extent[0][0] =
    extent[0][1] =
    extent[1][0] =
    extent[1][1] = 0;
    return brush;
  };

  brush.empty = function() {
    return (x && extent[0][0] === extent[1][0])
        || (y && extent[0][1] === extent[1][1]);
  };

  d3.select(window)
      .on("mousemove.brush", d3_svg_brushMove)
      .on("mouseup.brush", d3_svg_brushUp)
      .on("keydown.brush", d3_svg_brushKeydown)
      .on("keyup.brush", d3_svg_brushKeyup);

  return d3.rebind(brush, event, "on");
};

var d3_svg_brush,
    d3_svg_brushDispatch,
    d3_svg_brushTarget,
    d3_svg_brushX,
    d3_svg_brushY,
    d3_svg_brushExtent,
    d3_svg_brushDrag,
    d3_svg_brushResize,
    d3_svg_brushCenter,
    d3_svg_brushOffset;

function d3_svg_brushRedrawX(g, extent) {
  g.select(".extent").attr("x", extent[0][0]);
  g.selectAll(".n,.s,.w,.nw,.sw").attr("x", extent[0][0] - 2);
  g.selectAll(".e,.ne,.se").attr("x", extent[1][0] - 3);
  g.selectAll(".extent,.n,.s").attr("width", extent[1][0] - extent[0][0]);
}

function d3_svg_brushRedrawY(g, extent) {
  g.select(".extent").attr("y", extent[0][1]);
  g.selectAll(".n,.e,.w,.nw,.ne").attr("y", extent[0][1] - 3);
  g.selectAll(".s,.se,.sw").attr("y", extent[1][1] - 4);
  g.selectAll(".extent,.e,.w").attr("height", extent[1][1] - extent[0][1]);
}

function d3_svg_brushKeydown() {
  if (d3.event.keyCode == 32 && d3_svg_brushTarget && !d3_svg_brushDrag) {
    d3_svg_brushCenter = null;
    d3_svg_brushOffset[0] -= d3_svg_brushExtent[1][0];
    d3_svg_brushOffset[1] -= d3_svg_brushExtent[1][1];
    d3_svg_brushDrag = 2;
    d3_eventCancel();
  }
}

function d3_svg_brushKeyup() {
  if (d3.event.keyCode == 32 && d3_svg_brushDrag == 2) {
    d3_svg_brushOffset[0] += d3_svg_brushExtent[1][0];
    d3_svg_brushOffset[1] += d3_svg_brushExtent[1][1];
    d3_svg_brushDrag = 0;
    d3_eventCancel();
  }
}

function d3_svg_brushMove() {
  if (d3_svg_brushOffset) {
    var mouse = d3.svg.mouse(d3_svg_brushTarget),
        g = d3.select(d3_svg_brushTarget);

    if (!d3_svg_brushDrag) {

      // If needed, determine the center from the current extent.
      if (d3.event.altKey) {
        if (!d3_svg_brushCenter) {
          d3_svg_brushCenter = [
            (d3_svg_brushExtent[0][0] + d3_svg_brushExtent[1][0]) / 2,
            (d3_svg_brushExtent[0][1] + d3_svg_brushExtent[1][1]) / 2
          ];
        }

        // Update the offset, for when the ALT key is released.
        d3_svg_brushOffset[0] = d3_svg_brushExtent[+(mouse[0] < d3_svg_brushCenter[0])][0];
        d3_svg_brushOffset[1] = d3_svg_brushExtent[+(mouse[1] < d3_svg_brushCenter[1])][1];
      }

      // When the ALT key is released, we clear the center.
      else d3_svg_brushCenter = null;
    }

    // Update the brush extent for each dimension.
    if (d3_svg_brushX) {
      d3_svg_brushMove1(mouse, d3_svg_brushX, 0);
      d3_svg_brushRedrawX(g, d3_svg_brushExtent);
    }
    if (d3_svg_brushY) {
      d3_svg_brushMove1(mouse, d3_svg_brushY, 1);
      d3_svg_brushRedrawY(g, d3_svg_brushExtent);
    }

    // Notify listeners.
    d3_svg_brushDispatch("brush");
  }
}

function d3_svg_brushMove1(mouse, scale, i) {
  var range = d3_scaleRange(scale),
      r0 = range[0],
      r1 = range[1],
      offset = d3_svg_brushOffset[i],
      size = d3_svg_brushExtent[1][i] - d3_svg_brushExtent[0][i],
      min,
      max;

  // When dragging, reduce the range by the extent size and offset.
  if (d3_svg_brushDrag) {
    r0 -= offset;
    r1 -= size + offset;
  }

  // Clamp the mouse so that the extent fits within the range extent.
  min = Math.max(r0, Math.min(r1, mouse[i]));

  // Compute the new extent bounds.
  if (d3_svg_brushDrag) {
    max = (min += offset) + size;
  } else {

    // If the ALT key is pressed, then preserve the center of the extent.
    if (d3_svg_brushCenter) offset = Math.max(r0, Math.min(r1, 2 * d3_svg_brushCenter[i] - min));

    // Compute the min and max of the offset and mouse.
    if (offset < min) {
      max = min;
      min = offset;
    } else {
      max = offset;
    }
  }

  // Update the stored bounds.
  d3_svg_brushExtent[0][i] = min;
  d3_svg_brushExtent[1][i] = max;
}

function d3_svg_brushUp() {
  if (d3_svg_brushOffset) {
    d3_svg_brushMove();
    d3.select(d3_svg_brushTarget).selectAll(".resize").style("pointer-events", d3_svg_brush.empty() ? "none" : "all");
    d3_svg_brushDispatch("brushend");
    d3_svg_brush =
    d3_svg_brushDispatch =
    d3_svg_brushTarget =
    d3_svg_brushX =
    d3_svg_brushY =
    d3_svg_brushExtent =
    d3_svg_brushDrag =
    d3_svg_brushResize =
    d3_svg_brushCenter =
    d3_svg_brushOffset = null;
    d3_eventCancel();
  }
}

var d3_svg_brushCursor = {
  n: "ns-resize",
  e: "ew-resize",
  s: "ns-resize",
  w: "ew-resize",
  nw: "nwse-resize",
  ne: "nesw-resize",
  se: "nwse-resize",
  sw: "nesw-resize"
};
d3.behavior = {};
// TODO Track touch points by identifier.

d3.behavior.drag = function() {
  var event = d3.dispatch("drag", "dragstart", "dragend"),
      origin = null;

  function drag() {
    this
        .on("mousedown.drag", mousedown)
        .on("touchstart.drag", mousedown);

    d3.select(window)
        .on("mousemove.drag", d3_behavior_dragMove)
        .on("touchmove.drag", d3_behavior_dragMove)
        .on("mouseup.drag", d3_behavior_dragUp, true)
        .on("touchend.drag", d3_behavior_dragUp, true)
        .on("click.drag", d3_behavior_dragClick, true);
  }

  // snapshot the local context for subsequent dispatch
  function start() {
    d3_behavior_dragEvent = event;
    d3_behavior_dragEventTarget = d3.event.target;
    d3_behavior_dragTarget = this;
    d3_behavior_dragArguments = arguments;
    d3_behavior_dragOrigin = d3_behavior_dragPoint();
    if (origin) {
      d3_behavior_dragOffset = origin.apply(d3_behavior_dragTarget, d3_behavior_dragArguments);
      d3_behavior_dragOffset = [d3_behavior_dragOffset.x - d3_behavior_dragOrigin[0], d3_behavior_dragOffset.y - d3_behavior_dragOrigin[1]];
    } else {
      d3_behavior_dragOffset = [0, 0];
    }
    d3_behavior_dragMoved = 0;
  }

  function mousedown() {
    start.apply(this, arguments);
    d3_behavior_dragDispatch("dragstart");
  }

  drag.origin = function(x) {
    if (!arguments.length) return origin;
    origin = x;
    return drag;
  };

  return d3.rebind(drag, event, "on");
};

var d3_behavior_dragEvent,
    d3_behavior_dragEventTarget,
    d3_behavior_dragTarget,
    d3_behavior_dragArguments,
    d3_behavior_dragOffset,
    d3_behavior_dragOrigin,
    d3_behavior_dragMoved;

function d3_behavior_dragDispatch(type) {
  var p = d3_behavior_dragPoint(),
      o = d3.event,
      e = d3.event = {type: type};

  if (p) {
    e.x = p[0] + d3_behavior_dragOffset[0];
    e.y = p[1] + d3_behavior_dragOffset[1];
    e.dx = p[0] - d3_behavior_dragOrigin[0];
    e.dy = p[1] - d3_behavior_dragOrigin[1];
    d3_behavior_dragMoved |= e.dx | e.dy;
    d3_behavior_dragOrigin = p;
  }

  try {
    d3_behavior_dragEvent[type].apply(d3_behavior_dragTarget, d3_behavior_dragArguments);
  } finally {
    d3.event = o;
  }

  o.stopPropagation();
  o.preventDefault();
}

function d3_behavior_dragPoint() {
  var p = d3_behavior_dragTarget.parentNode,
      t = d3.event.changedTouches;
  return p && (t
      ? d3.svg.touches(p, t)[0]
      : d3.svg.mouse(p));
}

function d3_behavior_dragMove() {
  if (!d3_behavior_dragTarget) return;
  var parent = d3_behavior_dragTarget.parentNode;

  // O NOES! The drag element was removed from the DOM.
  if (!parent) return d3_behavior_dragUp();

  d3_behavior_dragDispatch("drag");
  d3_eventCancel();
}

function d3_behavior_dragUp() {
  if (!d3_behavior_dragTarget) return;
  d3_behavior_dragDispatch("dragend");

  // If the node was moved, prevent the mouseup from propagating.
  // Also prevent the subsequent click from propagating (e.g., for anchors).
  if (d3_behavior_dragMoved) {
    d3_eventCancel();
    d3_behavior_dragMoved = d3.event.target === d3_behavior_dragEventTarget;
  }

  d3_behavior_dragEvent =
  d3_behavior_dragEventTarget =
  d3_behavior_dragTarget =
  d3_behavior_dragArguments =
  d3_behavior_dragOffset =
  d3_behavior_dragOrigin = null;
}

function d3_behavior_dragClick() {
  if (d3_behavior_dragMoved) {
    d3_eventCancel();
    d3_behavior_dragMoved = 0;
  }
}
// TODO unbind zoom behavior?
d3.behavior.zoom = function() {
  var xyz = [0, 0, 0],
      event = d3.dispatch("zoom"),
      extent = d3_behavior_zoomInfiniteExtent;

  function zoom() {
    this
        .on("mousedown.zoom", mousedown)
        .on("mousewheel.zoom", mousewheel)
        .on("DOMMouseScroll.zoom", mousewheel)
        .on("dblclick.zoom", dblclick)
        .on("touchstart.zoom", touchstart);

    d3.select(window)
        .on("mousemove.zoom", d3_behavior_zoomMousemove)
        .on("mouseup.zoom", d3_behavior_zoomMouseup)
        .on("touchmove.zoom", d3_behavior_zoomTouchmove)
        .on("touchend.zoom", d3_behavior_zoomTouchup)
        .on("click.zoom", d3_behavior_zoomClick, true);
  }

  // snapshot the local context for subsequent dispatch
  function start() {
    d3_behavior_zoomXyz = xyz;
    d3_behavior_zoomExtent = extent;
    d3_behavior_zoomDispatch = event.zoom;
    d3_behavior_zoomEventTarget = d3.event.target;
    d3_behavior_zoomTarget = this;
    d3_behavior_zoomArguments = arguments;
  }

  function mousedown() {
    start.apply(this, arguments);
    d3_behavior_zoomPanning = d3_behavior_zoomLocation(d3.svg.mouse(d3_behavior_zoomTarget));
    d3_behavior_zoomMoved = 0;
    d3.event.preventDefault();
    window.focus();
  }

  // store starting mouse location
  function mousewheel() {
    start.apply(this, arguments);
    if (!d3_behavior_zoomZooming) d3_behavior_zoomZooming = d3_behavior_zoomLocation(d3.svg.mouse(d3_behavior_zoomTarget));
    d3_behavior_zoomTo(d3_behavior_zoomDelta() + xyz[2], d3.svg.mouse(d3_behavior_zoomTarget), d3_behavior_zoomZooming);
  }

  function dblclick() {
    start.apply(this, arguments);
    var mouse = d3.svg.mouse(d3_behavior_zoomTarget);
    d3_behavior_zoomTo(d3.event.shiftKey ? Math.ceil(xyz[2] - 1) : Math.floor(xyz[2] + 1), mouse, d3_behavior_zoomLocation(mouse));
  }

  // doubletap detection
  function touchstart() {
    start.apply(this, arguments);
    var touches = d3_behavior_zoomTouchup(),
        touch,
        now = Date.now();
    if ((touches.length === 1) && (now - d3_behavior_zoomLast < 300)) {
      d3_behavior_zoomTo(1 + Math.floor(xyz[2]), touch = touches[0], d3_behavior_zoomLocations[touch.identifier]);
    }
    d3_behavior_zoomLast = now;
  }

  zoom.extent = function(x) {
    if (!arguments.length) return extent;
    extent = x == null ? d3_behavior_zoomInfiniteExtent : x;
    return zoom;
  };

  return d3.rebind(zoom, event, "on");
};

var d3_behavior_zoomDiv,
    d3_behavior_zoomPanning,
    d3_behavior_zoomZooming,
    d3_behavior_zoomLocations = {}, // identifier -> location
    d3_behavior_zoomLast = 0,
    d3_behavior_zoomXyz,
    d3_behavior_zoomExtent,
    d3_behavior_zoomDispatch,
    d3_behavior_zoomEventTarget,
    d3_behavior_zoomTarget,
    d3_behavior_zoomArguments,
    d3_behavior_zoomMoved;

function d3_behavior_zoomLocation(point) {
  return [
    point[0] - d3_behavior_zoomXyz[0],
    point[1] - d3_behavior_zoomXyz[1],
    d3_behavior_zoomXyz[2]
  ];
}

// detect the pixels that would be scrolled by this wheel event
function d3_behavior_zoomDelta() {

  // mousewheel events are totally broken!
  // https://bugs.webkit.org/show_bug.cgi?id=40441
  // not only that, but Chrome and Safari differ in re. to acceleration!
  if (!d3_behavior_zoomDiv) {
    d3_behavior_zoomDiv = d3.select("body").append("div")
        .style("visibility", "hidden")
        .style("top", 0)
        .style("height", 0)
        .style("width", 0)
        .style("overflow-y", "scroll")
      .append("div")
        .style("height", "2000px")
      .node().parentNode;
  }

  var e = d3.event, delta;
  try {
    d3_behavior_zoomDiv.scrollTop = 1000;
    d3_behavior_zoomDiv.dispatchEvent(e);
    delta = 1000 - d3_behavior_zoomDiv.scrollTop;
  } catch (error) {
    delta = e.wheelDelta || (-e.detail * 5);
  }

  return delta * .005;
}

// Note: Since we don't rotate, it's possible for the touches to become
// slightly detached from their original positions. Thus, we recompute the
// touch points on touchend as well as touchstart!
function d3_behavior_zoomTouchup() {
  var touches = d3.svg.touches(d3_behavior_zoomTarget),
      i = -1,
      n = touches.length,
      touch;
  while (++i < n) d3_behavior_zoomLocations[(touch = touches[i]).identifier] = d3_behavior_zoomLocation(touch);
  return touches;
}

function d3_behavior_zoomTouchmove() {
  var touches = d3.svg.touches(d3_behavior_zoomTarget);
  switch (touches.length) {

    // single-touch pan
    case 1: {
      var touch = touches[0];
      d3_behavior_zoomTo(d3_behavior_zoomXyz[2], touch, d3_behavior_zoomLocations[touch.identifier]);
      break;
    }

    // double-touch pan + zoom
    case 2: {
      var p0 = touches[0],
          p1 = touches[1],
          p2 = [(p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2],
          l0 = d3_behavior_zoomLocations[p0.identifier],
          l1 = d3_behavior_zoomLocations[p1.identifier],
          l2 = [(l0[0] + l1[0]) / 2, (l0[1] + l1[1]) / 2, l0[2]];
      d3_behavior_zoomTo(Math.log(d3.event.scale) / Math.LN2 + l0[2], p2, l2);
      break;
    }
  }
}

function d3_behavior_zoomMousemove() {
  d3_behavior_zoomZooming = null;
  if (d3_behavior_zoomPanning) {
    d3_behavior_zoomMoved = 1;
    d3_behavior_zoomTo(d3_behavior_zoomXyz[2], d3.svg.mouse(d3_behavior_zoomTarget), d3_behavior_zoomPanning);
  }
}

function d3_behavior_zoomMouseup() {
  if (d3_behavior_zoomPanning) {
    if (d3_behavior_zoomMoved) {
      d3_eventCancel();
      d3_behavior_zoomMoved = d3_behavior_zoomEventTarget === d3.event.target;
    }

    d3_behavior_zoomXyz =
    d3_behavior_zoomExtent =
    d3_behavior_zoomDispatch =
    d3_behavior_zoomEventTarget =
    d3_behavior_zoomTarget =
    d3_behavior_zoomArguments =
    d3_behavior_zoomPanning = null;
  }
}

function d3_behavior_zoomClick() {
  if (d3_behavior_zoomMoved) {
    d3_eventCancel();
    d3_behavior_zoomMoved = 0;
  }
}

function d3_behavior_zoomTo(z, x0, x1) {
  z = d3_behavior_zoomExtentClamp(z, 2);
  var j = Math.pow(2, d3_behavior_zoomXyz[2]),
      k = Math.pow(2, z),
      K = Math.pow(2, (d3_behavior_zoomXyz[2] = z) - x1[2]),
      x_ = d3_behavior_zoomXyz[0],
      y_ = d3_behavior_zoomXyz[1],
      x = d3_behavior_zoomXyz[0] = d3_behavior_zoomExtentClamp((x0[0] - x1[0] * K), 0, k),
      y = d3_behavior_zoomXyz[1] = d3_behavior_zoomExtentClamp((x0[1] - x1[1] * K), 1, k),
      o = d3.event; // Events can be reentrant (e.g., focus).

  d3.event = {
    scale: k,
    translate: [x, y],
    transform: function(sx, sy) {
      if (sx) transform(sx, x_, x);
      if (sy) transform(sy, y_, y);
    }
  };

  function transform(scale, a, b) {
    scale.domain(scale.range().map(function(v) { return scale.invert(((v - b) * j) / k + a); }));
  }

  try {
    d3_behavior_zoomDispatch.apply(d3_behavior_zoomTarget, d3_behavior_zoomArguments);
  } finally {
    d3.event = o;
  }

  o.preventDefault();
}

var d3_behavior_zoomInfiniteExtent = [
  [-Infinity, Infinity],
  [-Infinity, Infinity],
  [-Infinity, Infinity]
];

function d3_behavior_zoomExtentClamp(x, i, k) {
  var range = d3_behavior_zoomExtent[i],
      r0 = range[0],
      r1 = range[1];
  return arguments.length === 3
      ? Math.max(r1 * (r1 === Infinity ? -Infinity : 1 / k - 1),
        Math.min(r0 === -Infinity ? Infinity : r0, x / k)) * k
      : Math.max(r0, Math.min(r1, x));
}
})();
(function(){d3.chart = {};
// Inspired by http://informationandvisualization.de/blog/box-plot
d3.chart.box = function() {
  var width = 1,
      height = 1,
      duration = 0,
      domain = null,
      value = Number,
      whiskers = d3_chart_boxWhiskers,
      quartiles = d3_chart_boxQuartiles,
      tickFormat = null;

  // For each small multiple…
  function box(g) {
    g.each(function(d, i) {
      d = d.map(value).sort(d3.ascending);
      var g = d3.select(this),
          n = d.length,
          min = d[0],
          max = d[n - 1];

      // Compute quartiles. Must return exactly 3 elements.
      var quartileData = d.quartiles = quartiles(d);

      // Compute whiskers. Must return exactly 2 elements, or null.
      var whiskerIndices = whiskers && whiskers.call(this, d, i),
          whiskerData = whiskerIndices && whiskerIndices.map(function(i) { return d[i]; });

      // Compute outliers. If no whiskers are specified, all data are "outliers".
      // We compute the outliers as indices, so that we can join across transitions!
      var outlierIndices = whiskerIndices
          ? d3.range(0, whiskerIndices[0]).concat(d3.range(whiskerIndices[1] + 1, n))
          : d3.range(n);

      // Compute the new x-scale.
      var x1 = d3.scale.linear()
          .domain(domain && domain.call(this, d, i) || [min, max])
          .range([height, 0]);

      // Retrieve the old x-scale, if this is an update.
      var x0 = this.__chart__ || d3.scale.linear()
          .domain([0, Infinity])
          .range(x1.range());

      // Stash the new scale.
      this.__chart__ = x1;

      // Note: the box, median, and box tick elements are fixed in number,
      // so we only have to handle enter and update. In contrast, the outliers
      // and other elements are variable, so we need to exit them! Variable
      // elements also fade in and out.

      // Update center line: the vertical line spanning the whiskers.
      var center = g.selectAll("line.center")
          .data(whiskerData ? [whiskerData] : []);

      center.enter().insert("svg:line", "rect")
          .attr("class", "center")
          .attr("x1", width / 2)
          .attr("y1", function(d) { return x0(d[0]); })
          .attr("x2", width / 2)
          .attr("y2", function(d) { return x0(d[1]); })
          .style("opacity", 1e-6)
        .transition()
          .duration(duration)
          .style("opacity", 1)
          .attr("y1", function(d) { return x1(d[0]); })
          .attr("y2", function(d) { return x1(d[1]); });

      center.transition()
          .duration(duration)
          .style("opacity", 1)
          .attr("y1", function(d) { return x1(d[0]); })
          .attr("y2", function(d) { return x1(d[1]); });

      center.exit().transition()
          .duration(duration)
          .style("opacity", 1e-6)
          .attr("y1", function(d) { return x1(d[0]); })
          .attr("y2", function(d) { return x1(d[1]); })
          .remove();

      // Update innerquartile box.
      var box = g.selectAll("rect.box")
          .data([quartileData]);

      box.enter().append("svg:rect")
          .attr("class", "box")
          .attr("x", 0)
          .attr("y", function(d) { return x0(d[2]); })
          .attr("width", width)
          .attr("height", function(d) { return x0(d[0]) - x0(d[2]); })
        .transition()
          .duration(duration)
          .attr("y", function(d) { return x1(d[2]); })
          .attr("height", function(d) { return x1(d[0]) - x1(d[2]); });

      box.transition()
          .duration(duration)
          .attr("y", function(d) { return x1(d[2]); })
          .attr("height", function(d) { return x1(d[0]) - x1(d[2]); });

      // Update median line.
      var medianLine = g.selectAll("line.median")
          .data([quartileData[1]]);

      medianLine.enter().append("svg:line")
          .attr("class", "median")
          .attr("x1", 0)
          .attr("y1", x0)
          .attr("x2", width)
          .attr("y2", x0)
        .transition()
          .duration(duration)
          .attr("y1", x1)
          .attr("y2", x1);

      medianLine.transition()
          .duration(duration)
          .attr("y1", x1)
          .attr("y2", x1);

      // Update whiskers.
      var whisker = g.selectAll("line.whisker")
          .data(whiskerData || []);

      whisker.enter().insert("svg:line", "circle, text")
          .attr("class", "whisker")
          .attr("x1", 0)
          .attr("y1", x0)
          .attr("x2", width)
          .attr("y2", x0)
          .style("opacity", 1e-6)
        .transition()
          .duration(duration)
          .attr("y1", x1)
          .attr("y2", x1)
          .style("opacity", 1);

      whisker.transition()
          .duration(duration)
          .attr("y1", x1)
          .attr("y2", x1)
          .style("opacity", 1);

      whisker.exit().transition()
          .duration(duration)
          .attr("y1", x1)
          .attr("y2", x1)
          .style("opacity", 1e-6)
          .remove();

      // Update outliers.
      var outlier = g.selectAll("circle.outlier")
          .data(outlierIndices, Number);

      outlier.enter().insert("svg:circle", "text")
          .attr("class", "outlier")
          .attr("r", 5)
          .attr("cx", width / 2)
          .attr("cy", function(i) { return x0(d[i]); })
          .style("opacity", 1e-6)
        .transition()
          .duration(duration)
          .attr("cy", function(i) { return x1(d[i]); })
          .style("opacity", 1);

      outlier.transition()
          .duration(duration)
          .attr("cy", function(i) { return x1(d[i]); })
          .style("opacity", 1);

      outlier.exit().transition()
          .duration(duration)
          .attr("cy", function(i) { return x1(d[i]); })
          .style("opacity", 1e-6)
          .remove();

      // Compute the tick format.
      var format = tickFormat || x1.tickFormat(8);

      // Update box ticks.
      var boxTick = g.selectAll("text.box")
          .data(quartileData);

      boxTick.enter().append("svg:text")
          .attr("class", "box")
          .attr("dy", ".3em")
          .attr("dx", function(d, i) { return i & 1 ? 6 : -6 })
          .attr("x", function(d, i) { return i & 1 ? width : 0 })
          .attr("y", x0)
          .attr("text-anchor", function(d, i) { return i & 1 ? "start" : "end"; })
          .text(format)
        .transition()
          .duration(duration)
          .attr("y", x1);

      boxTick.transition()
          .duration(duration)
          .text(format)
          .attr("y", x1);

      // Update whisker ticks. These are handled separately from the box
      // ticks because they may or may not exist, and we want don't want
      // to join box ticks pre-transition with whisker ticks post-.
      var whiskerTick = g.selectAll("text.whisker")
          .data(whiskerData || []);

      whiskerTick.enter().append("svg:text")
          .attr("class", "whisker")
          .attr("dy", ".3em")
          .attr("dx", 6)
          .attr("x", width)
          .attr("y", x0)
          .text(format)
          .style("opacity", 1e-6)
        .transition()
          .duration(duration)
          .attr("y", x1)
          .style("opacity", 1);

      whiskerTick.transition()
          .duration(duration)
          .text(format)
          .attr("y", x1)
          .style("opacity", 1);

      whiskerTick.exit().transition()
          .duration(duration)
          .attr("y", x1)
          .style("opacity", 1e-6)
          .remove();
    });
    d3.timer.flush();
  }

  box.width = function(x) {
    if (!arguments.length) return width;
    width = x;
    return box;
  };

  box.height = function(x) {
    if (!arguments.length) return height;
    height = x;
    return box;
  };

  box.tickFormat = function(x) {
    if (!arguments.length) return tickFormat;
    tickFormat = x;
    return box;
  };

  box.duration = function(x) {
    if (!arguments.length) return duration;
    duration = x;
    return box;
  };

  box.domain = function(x) {
    if (!arguments.length) return domain;
    domain = x == null ? x : d3.functor(x);
    return box;
  };

  box.value = function(x) {
    if (!arguments.length) return value;
    value = x;
    return box;
  };

  box.whiskers = function(x) {
    if (!arguments.length) return whiskers;
    whiskers = x;
    return box;
  };

  box.quartiles = function(x) {
    if (!arguments.length) return quartiles;
    quartiles = x;
    return box;
  };

  return box;
};

function d3_chart_boxWhiskers(d) {
  return [0, d.length - 1];
}

function d3_chart_boxQuartiles(d) {
  return [
    d3.quantile(d, .25),
    d3.quantile(d, .5),
    d3.quantile(d, .75)
  ];
}
// Chart design based on the recommendations of Stephen Few. Implementation
// based on the work of Clint Ivy, Jamie Love, and Jason Davies.
// http://projects.instantcognition.com/protovis/bulletchart/
d3.chart.bullet = function() {
  var orient = "left", // TODO top & bottom
      reverse = false,
      duration = 0,
      ranges = d3_chart_bulletRanges,
      markers = d3_chart_bulletMarkers,
      measures = d3_chart_bulletMeasures,
      width = 380,
      height = 30,
      tickFormat = null;

  // For each small multiple…
  function bullet(g) {
    g.each(function(d, i) {
      var rangez = ranges.call(this, d, i).slice().sort(d3.descending),
          markerz = markers.call(this, d, i).slice().sort(d3.descending),
          measurez = measures.call(this, d, i).slice().sort(d3.descending),
          g = d3.select(this);

      // Compute the new x-scale.
      var x1 = d3.scale.linear()
          .domain([0, Math.max(rangez[0], markerz[0], measurez[0])])
          .range(reverse ? [width, 0] : [0, width]);

      // Retrieve the old x-scale, if this is an update.
      var x0 = this.__chart__ || d3.scale.linear()
          .domain([0, Infinity])
          .range(x1.range());

      // Stash the new scale.
      this.__chart__ = x1;

      // Derive width-scales from the x-scales.
      var w0 = d3_chart_bulletWidth(x0),
          w1 = d3_chart_bulletWidth(x1);

      // Update the range rects.
      var range = g.selectAll("rect.range")
          .data(rangez);

      range.enter().append("svg:rect")
          .attr("class", function(d, i) { return "range s" + i; })
          .attr("width", w0)
          .attr("height", height)
          .attr("x", reverse ? x0 : 0)
        .transition()
          .duration(duration)
          .attr("width", w1)
          .attr("x", reverse ? x1 : 0);

      range.transition()
          .duration(duration)
          .attr("x", reverse ? x1 : 0)
          .attr("width", w1)
          .attr("height", height);

      // Update the measure rects.
      var measure = g.selectAll("rect.measure")
          .data(measurez);

      measure.enter().append("svg:rect")
          .attr("class", function(d, i) { return "measure s" + i; })
          .attr("width", w0)
          .attr("height", height / 3)
          .attr("x", reverse ? x0 : 0)
          .attr("y", height / 3)
        .transition()
          .duration(duration)
          .attr("width", w1)
          .attr("x", reverse ? x1 : 0);

      measure.transition()
          .duration(duration)
          .attr("width", w1)
          .attr("height", height / 3)
          .attr("x", reverse ? x1 : 0)
          .attr("y", height / 3);

      // Update the marker lines.
      var marker = g.selectAll("line.marker")
          .data(markerz);

      marker.enter().append("svg:line")
          .attr("class", "marker")
          .attr("x1", x0)
          .attr("x2", x0)
          .attr("y1", height / 6)
          .attr("y2", height * 5 / 6)
        .transition()
          .duration(duration)
          .attr("x1", x1)
          .attr("x2", x1);

      marker.transition()
          .duration(duration)
          .attr("x1", x1)
          .attr("x2", x1)
          .attr("y1", height / 6)
          .attr("y2", height * 5 / 6);

      // Compute the tick format.
      var format = tickFormat || x1.tickFormat(8);

      // Update the tick groups.
      var tick = g.selectAll("g.tick")
          .data(x1.ticks(8), function(d) {
            return this.textContent || format(d);
          });

      // Initialize the ticks with the old scale, x0.
      var tickEnter = tick.enter().append("svg:g")
          .attr("class", "tick")
          .attr("transform", d3_chart_bulletTranslate(x0))
          .style("opacity", 1e-6);

      tickEnter.append("svg:line")
          .attr("y1", height)
          .attr("y2", height * 7 / 6);

      tickEnter.append("svg:text")
          .attr("text-anchor", "middle")
          .attr("dy", "1em")
          .attr("y", height * 7 / 6)
          .text(format);

      // Transition the entering ticks to the new scale, x1.
      tickEnter.transition()
          .duration(duration)
          .attr("transform", d3_chart_bulletTranslate(x1))
          .style("opacity", 1);

      // Transition the updating ticks to the new scale, x1.
      var tickUpdate = tick.transition()
          .duration(duration)
          .attr("transform", d3_chart_bulletTranslate(x1))
          .style("opacity", 1);

      tickUpdate.select("line")
          .attr("y1", height)
          .attr("y2", height * 7 / 6);

      tickUpdate.select("text")
          .attr("y", height * 7 / 6);

      // Transition the exiting ticks to the new scale, x1.
      tick.exit().transition()
          .duration(duration)
          .attr("transform", d3_chart_bulletTranslate(x1))
          .style("opacity", 1e-6)
          .remove();
    });
    d3.timer.flush();
  }

  // left, right, top, bottom
  bullet.orient = function(x) {
    if (!arguments.length) return orient;
    orient = x;
    reverse = orient == "right" || orient == "bottom";
    return bullet;
  };

  // ranges (bad, satisfactory, good)
  bullet.ranges = function(x) {
    if (!arguments.length) return ranges;
    ranges = x;
    return bullet;
  };

  // markers (previous, goal)
  bullet.markers = function(x) {
    if (!arguments.length) return markers;
    markers = x;
    return bullet;
  };

  // measures (actual, forecast)
  bullet.measures = function(x) {
    if (!arguments.length) return measures;
    measures = x;
    return bullet;
  };

  bullet.width = function(x) {
    if (!arguments.length) return width;
    width = x;
    return bullet;
  };

  bullet.height = function(x) {
    if (!arguments.length) return height;
    height = x;
    return bullet;
  };

  bullet.tickFormat = function(x) {
    if (!arguments.length) return tickFormat;
    tickFormat = x;
    return bullet;
  };

  bullet.duration = function(x) {
    if (!arguments.length) return duration;
    duration = x;
    return bullet;
  };

  return bullet;
};

function d3_chart_bulletRanges(d) {
  return d.ranges;
}

function d3_chart_bulletMarkers(d) {
  return d.markers;
}

function d3_chart_bulletMeasures(d) {
  return d.measures;
}

function d3_chart_bulletTranslate(x) {
  return function(d) {
    return "translate(" + x(d) + ",0)";
  };
}

function d3_chart_bulletWidth(x) {
  var x0 = x(0);
  return function(d) {
    return Math.abs(x(d) - x0);
  };
}
// Implements a horizon layout, which is a variation of a single-series
// area chart where the area is folded into multiple bands. Color is used to
// encode band, allowing the size of the chart to be reduced significantly
// without impeding readability. This layout algorithm is based on the work of
// J. Heer, N. Kong and M. Agrawala in "Sizing the Horizon: The Effects of Chart
// Size and Layering on the Graphical Perception of Time Series Visualizations",
// CHI 2009. http://hci.stanford.edu/publications/2009/heer-horizon-chi09.pdf
d3.chart.horizon = function() {
  var bands = 1, // between 1 and 5, typically
      mode = "offset", // or mirror
      interpolate = "linear", // or basis, monotone, step-before, etc.
      x = d3_chart_horizonX,
      y = d3_chart_horizonY,
      w = 960,
      h = 40,
      duration = 0;

  var color = d3.scale.linear()
      .domain([-1, 0, 1])
      .range(["#d62728", "#fff", "#1f77b4"]);

  // For each small multiple…
  function horizon(g) {
    g.each(function(d, i) {
      var g = d3.select(this),
          n = 2 * bands + 1,
          xMin = Infinity,
          xMax = -Infinity,
          yMax = -Infinity,
          x0, // old x-scale
          y0, // old y-scale
          id; // unique id for paths

      // Compute x- and y-values along with extents.
      var data = d.map(function(d, i) {
        var xv = x.call(this, d, i),
            yv = y.call(this, d, i);
        if (xv < xMin) xMin = xv;
        if (xv > xMax) xMax = xv;
        if (-yv > yMax) yMax = -yv;
        if (yv > yMax) yMax = yv;
        return [xv, yv];
      });

      // Compute the new x- and y-scales.
      var x1 = d3.scale.linear().domain([xMin, xMax]).range([0, w]),
          y1 = d3.scale.linear().domain([0, yMax]).range([0, h * bands]);

      // Retrieve the old scales, if this is an update.
      if (this.__chart__) {
        x0 = this.__chart__.x;
        y0 = this.__chart__.y;
        id = this.__chart__.id;
      } else {
        x0 = d3.scale.linear().domain([0, Infinity]).range(x1.range());
        y0 = d3.scale.linear().domain([0, Infinity]).range(y1.range());
        id = ++d3_chart_horizonId;
      }

      // We'll use a defs to store the area path and the clip path.
      var defs = g.selectAll("defs")
          .data([data]);

      var defsEnter = defs.enter().append("svg:defs");

      // The clip path is a simple rect.
      defsEnter.append("svg:clipPath")
          .attr("id", "d3_chart_horizon_clip" + id)
        .append("svg:rect")
          .attr("width", w)
          .attr("height", h);

      defs.select("rect").transition()
          .duration(duration)
          .attr("width", w)
          .attr("height", h);

      // The area path is rendered with our resuable d3.svg.area.
      defsEnter.append("svg:path")
          .attr("id", "d3_chart_horizon_path" + id)
          .attr("d", d3_chart_horizonArea
          .interpolate(interpolate)
          .x(function(d) { return x0(d[0]); })
          .y0(h * bands)
          .y1(function(d) { return h * bands - y0(d[1]); }))
        .transition()
          .duration(duration)
          .attr("d", d3_chart_horizonArea
          .x(function(d) { return x1(d[0]); })
          .y1(function(d) { return h * bands - y1(d[1]); }));

      defs.select("path").transition()
          .duration(duration)
          .attr("d", d3_chart_horizonArea);

      // We'll use a container to clip all horizon layers at once.
      g.selectAll("g")
          .data([null])
        .enter().append("svg:g")
          .attr("clip-path", "url(#d3_chart_horizon_clip" + id + ")");

      // Define the transform function based on the mode.
      var transform = mode == "offset"
          ? function(d) { return "translate(0," + (d + (d < 0) - bands) * h + ")"; }
          : function(d) { return (d < 0 ? "scale(1,-1)" : "") + "translate(0," + (d - bands) * h + ")"; };

      // Instantiate each copy of the path with different transforms.
      var u = g.select("g").selectAll("use")
          .data(d3.range(-1, -bands - 1, -1).concat(d3.range(1, bands + 1)), Number);

      // TODO don't fudge the enter transition
      u.enter().append("svg:use")
          .attr("xlink:href", "#d3_chart_horizon_path" + id)
          .attr("transform", function(d) { return transform(d + (d > 0 ? 1 : -1)); })
          .style("fill", color)
        .transition()
          .duration(duration)
          .attr("transform", transform);

      u.transition()
          .duration(duration)
          .attr("transform", transform)
          .style("fill", color);

      u.exit().transition()
          .duration(duration)
          .attr("transform", transform)
          .remove();

      // Stash the new scales.
      this.__chart__ = {x: x1, y: y1, id: id};
    });
    d3.timer.flush();
  }

  horizon.duration = function(x) {
    if (!arguments.length) return duration;
    duration = +x;
    return horizon;
  };

  horizon.bands = function(x) {
    if (!arguments.length) return bands;
    bands = +x;
    color.domain([-bands, 0, bands]);
    return horizon;
  };

  horizon.mode = function(x) {
    if (!arguments.length) return mode;
    mode = x + "";
    return horizon;
  };

  horizon.colors = function(x) {
    if (!arguments.length) return color.range();
    color.range(x);
    return horizon;
  };

  horizon.interpolate = function(x) {
    if (!arguments.length) return interpolate;
    interpolate = x + "";
    return horizon;
  };

  horizon.x = function(z) {
    if (!arguments.length) return x;
    x = z;
    return horizon;
  };

  horizon.y = function(z) {
    if (!arguments.length) return y;
    y = z;
    return horizon;
  };

  horizon.width = function(x) {
    if (!arguments.length) return w;
    w = +x;
    return horizon;
  };

  horizon.height = function(x) {
    if (!arguments.length) return h;
    h = +x;
    return horizon;
  };

  return horizon;
};

var d3_chart_horizonArea = d3.svg.area(),
    d3_chart_horizonId = 0;

function d3_chart_horizonX(d) {
  return d[0];
}

function d3_chart_horizonY(d) {
  return d[1];
}
// Based on http://vis.stanford.edu/protovis/ex/qqplot.html
d3.chart.qq = function() {
  var width = 1,
      height = 1,
      duration = 0,
      domain = null,
      tickFormat = null,
      n = 100,
      x = d3_chart_qqX,
      y = d3_chart_qqY;

  // For each small multiple…
  function qq(g) {
    g.each(function(d, i) {
      var g = d3.select(this),
          qx = d3_chart_qqQuantiles(n, x.call(this, d, i)),
          qy = d3_chart_qqQuantiles(n, y.call(this, d, i)),
          xd = domain && domain.call(this, d, i) || [d3.min(qx), d3.max(qx)], // new x-domain
          yd = domain && domain.call(this, d, i) || [d3.min(qy), d3.max(qy)], // new y-domain
          x0, // old x-scale
          y0; // old y-scale

      // Compute the new x-scale.
      var x1 = d3.scale.linear()
          .domain(xd)
          .range([0, width]);

      // Compute the new y-scale.
      var y1 = d3.scale.linear()
          .domain(yd)
          .range([height, 0]);

      // Retrieve the old scales, if this is an update.
      if (this.__chart__) {
        x0 = this.__chart__.x;
        y0 = this.__chart__.y;
      } else {
        x0 = d3.scale.linear().domain([0, Infinity]).range(x1.range());
        y0 = d3.scale.linear().domain([0, Infinity]).range(y1.range());
      }

      // Stash the new scales.
      this.__chart__ = {x: x1, y: y1};

      // Update diagonal line.
      var diagonal = g.selectAll("line.diagonal")
          .data([null]);

      diagonal.enter().append("svg:line")
          .attr("class", "diagonal")
          .attr("x1", x1(yd[0]))
          .attr("y1", y1(xd[0]))
          .attr("x2", x1(yd[1]))
          .attr("y2", y1(xd[1]));

      diagonal.transition()
          .duration(duration)
          .attr("x1", x1(yd[0]))
          .attr("y1", y1(xd[0]))
          .attr("x2", x1(yd[1]))
          .attr("y2", y1(xd[1]));

      // Update quantile plots.
      var circle = g.selectAll("circle")
          .data(d3.range(n).map(function(i) {
            return {x: qx[i], y: qy[i]};
          }));

      circle.enter().append("svg:circle")
          .attr("class", "quantile")
          .attr("r", 4.5)
          .attr("cx", function(d) { return x0(d.x); })
          .attr("cy", function(d) { return y0(d.y); })
          .style("opacity", 1e-6)
        .transition()
          .duration(duration)
          .attr("cx", function(d) { return x1(d.x); })
          .attr("cy", function(d) { return y1(d.y); })
          .style("opacity", 1);

      circle.transition()
          .duration(duration)
          .attr("cx", function(d) { return x1(d.x); })
          .attr("cy", function(d) { return y1(d.y); })
          .style("opacity", 1);

      circle.exit().transition()
          .duration(duration)
          .attr("cx", function(d) { return x1(d.x); })
          .attr("cy", function(d) { return y1(d.y); })
          .style("opacity", 1e-6)
          .remove();

      var xformat = tickFormat || x1.tickFormat(4),
          yformat = tickFormat || y1.tickFormat(4),
          tx = function(d) { return "translate(" + x1(d) + "," + height + ")"; },
          ty = function(d) { return "translate(0," + y1(d) + ")"; };

      // Update x-ticks.
      var xtick = g.selectAll("g.x.tick")
          .data(x1.ticks(4), function(d) {
            return this.textContent || xformat(d);
          });

      var xtickEnter = xtick.enter().append("svg:g")
          .attr("class", "x tick")
          .attr("transform", function(d) { return "translate(" + x0(d) + "," + height + ")"; })
          .style("opacity", 1e-6);

      xtickEnter.append("svg:line")
          .attr("y1", 0)
          .attr("y2", -6);

      xtickEnter.append("svg:text")
          .attr("text-anchor", "middle")
          .attr("dy", "1em")
          .text(xformat);

      // Transition the entering ticks to the new scale, x1.
      xtickEnter.transition()
          .duration(duration)
          .attr("transform", tx)
          .style("opacity", 1);

      // Transition the updating ticks to the new scale, x1.
      xtick.transition()
          .duration(duration)
          .attr("transform", tx)
          .style("opacity", 1);

      // Transition the exiting ticks to the new scale, x1.
      xtick.exit().transition()
          .duration(duration)
          .attr("transform", tx)
          .style("opacity", 1e-6)
          .remove();

      // Update ticks.
      var ytick = g.selectAll("g.y.tick")
          .data(y1.ticks(4), function(d) {
            return this.textContent || yformat(d);
          });

      var ytickEnter = ytick.enter().append("svg:g")
          .attr("class", "y tick")
          .attr("transform", function(d) { return "translate(0," + y0(d) + ")"; })
          .style("opacity", 1e-6);

      ytickEnter.append("svg:line")
          .attr("x1", 0)
          .attr("x2", 6);

      ytickEnter.append("svg:text")
          .attr("text-anchor", "end")
          .attr("dx", "-.5em")
          .attr("dy", ".3em")
          .text(yformat);

      // Transition the entering ticks to the new scale, y1.
      ytickEnter.transition()
          .duration(duration)
          .attr("transform", ty)
          .style("opacity", 1);

      // Transition the updating ticks to the new scale, y1.
      ytick.transition()
          .duration(duration)
          .attr("transform", ty)
          .style("opacity", 1);

      // Transition the exiting ticks to the new scale, y1.
      ytick.exit().transition()
          .duration(duration)
          .attr("transform", ty)
          .style("opacity", 1e-6)
          .remove();
    });
  }

  qq.width = function(x) {
    if (!arguments.length) return width;
    width = x;
    return qq;
  };

  qq.height = function(x) {
    if (!arguments.length) return height;
    height = x;
    return qq;
  };

  qq.duration = function(x) {
    if (!arguments.length) return duration;
    duration = x;
    return qq;
  };

  qq.domain = function(x) {
    if (!arguments.length) return domain;
    domain = x == null ? x : d3.functor(x);
    return qq;
  };

  qq.count = function(z) {
    if (!arguments.length) return n;
    n = z;
    return qq;
  };

  qq.x = function(z) {
    if (!arguments.length) return x;
    x = z;
    return qq;
  };

  qq.y = function(z) {
    if (!arguments.length) return y;
    y = z;
    return qq;
  };

  qq.tickFormat = function(x) {
    if (!arguments.length) return tickFormat;
    tickFormat = x;
    return qq;
  };

  return qq;
};

function d3_chart_qqQuantiles(n, values) {
  var m = values.length - 1;
  values = values.slice().sort(d3.ascending);
  return d3.range(n).map(function(i) {
    return values[~~(i * m / n)];
  });
}

function d3_chart_qqX(d) {
  return d.x;
}

function d3_chart_qqY(d) {
  return d.y;
}
})();
(function(){d3.layout = {};
// Implements hierarchical edge bundling using Holten's algorithm. For each
// input link, a path is computed that travels through the tree, up the parent
// hierarchy to the least common ancestor, and then back down to the destination
// node. Each path is simply an array of nodes.
d3.layout.bundle = function() {
  return function(links) {
    var paths = [],
        i = -1,
        n = links.length;
    while (++i < n) paths.push(d3_layout_bundlePath(links[i]));
    return paths;
  };
};

function d3_layout_bundlePath(link) {
  var start = link.source,
      end = link.target,
      lca = d3_layout_bundleLeastCommonAncestor(start, end),
      points = [start];
  while (start !== lca) {
    start = start.parent;
    points.push(start);
  }
  var k = points.length;
  while (end !== lca) {
    points.splice(k, 0, end);
    end = end.parent;
  }
  return points;
}

function d3_layout_bundleAncestors(node) {
  var ancestors = [],
      parent = node.parent;
  while (parent != null) {
    ancestors.push(node);
    node = parent;
    parent = parent.parent;
  }
  ancestors.push(node);
  return ancestors;
}

function d3_layout_bundleLeastCommonAncestor(a, b) {
  if (a === b) return a;
  var aNodes = d3_layout_bundleAncestors(a),
      bNodes = d3_layout_bundleAncestors(b),
      aNode = aNodes.pop(),
      bNode = bNodes.pop(),
      sharedNode = null;
  while (aNode === bNode) {
    sharedNode = aNode;
    aNode = aNodes.pop();
    bNode = bNodes.pop();
  }
  return sharedNode;
}
d3.layout.chord = function() {
  var chord = {},
      chords,
      groups,
      matrix,
      n,
      padding = 0,
      sortGroups,
      sortSubgroups,
      sortChords;

  function relayout() {
    var subgroups = {},
        groupSums = [],
        groupIndex = d3.range(n),
        subgroupIndex = [],
        k,
        x,
        x0,
        i,
        j;

    chords = [];
    groups = [];

    // Compute the sum.
    k = 0, i = -1; while (++i < n) {
      x = 0, j = -1; while (++j < n) {
        x += matrix[i][j];
      }
      groupSums.push(x);
      subgroupIndex.push(d3.range(n));
      k += x;
    }

    // Sort groups…
    if (sortGroups) {
      groupIndex.sort(function(a, b) {
        return sortGroups(groupSums[a], groupSums[b]);
      });
    }

    // Sort subgroups…
    if (sortSubgroups) {
      subgroupIndex.forEach(function(d, i) {
        d.sort(function(a, b) {
          return sortSubgroups(matrix[i][a], matrix[i][b]);
        });
      });
    }

    // Convert the sum to scaling factor for [0, 2pi].
    // TODO Allow start and end angle to be specified.
    // TODO Allow padding to be specified as percentage?
    k = (2 * Math.PI - padding * n) / k;

    // Compute the start and end angle for each group and subgroup.
    // Note: Opera has a bug reordering object literal properties!
    x = 0, i = -1; while (++i < n) {
      x0 = x, j = -1; while (++j < n) {
        var di = groupIndex[i],
            dj = subgroupIndex[di][j],
            v = matrix[di][dj],
            a0 = x,
            a1 = x += v * k;
        subgroups[di + "-" + dj] = {
          index: di,
          subindex: dj,
          startAngle: a0,
          endAngle: a1,
          value: v
        };
      }
      groups.push({
        index: di,
        startAngle: x0,
        endAngle: x,
        value: (x - x0) / k
      });
      x += padding;
    }

    // Generate chords for each (non-empty) subgroup-subgroup link.
    i = -1; while (++i < n) {
      j = i - 1; while (++j < n) {
        var source = subgroups[i + "-" + j],
            target = subgroups[j + "-" + i];
        if (source.value || target.value) {
          chords.push(source.value < target.value
              ? {source: target, target: source}
              : {source: source, target: target});
        }
      }
    }

    if (sortChords) resort();
  }

  function resort() {
    chords.sort(function(a, b) {
      return sortChords(
          (a.source.value + a.target.value) / 2,
          (b.source.value + b.target.value) / 2);
    });
  }

  chord.matrix = function(x) {
    if (!arguments.length) return matrix;
    n = (matrix = x) && matrix.length;
    chords = groups = null;
    return chord;
  };

  chord.padding = function(x) {
    if (!arguments.length) return padding;
    padding = x;
    chords = groups = null;
    return chord;
  };

  chord.sortGroups = function(x) {
    if (!arguments.length) return sortGroups;
    sortGroups = x;
    chords = groups = null;
    return chord;
  };

  chord.sortSubgroups = function(x) {
    if (!arguments.length) return sortSubgroups;
    sortSubgroups = x;
    chords = null;
    return chord;
  };

  chord.sortChords = function(x) {
    if (!arguments.length) return sortChords;
    sortChords = x;
    if (chords) resort();
    return chord;
  };

  chord.chords = function() {
    if (!chords) relayout();
    return chords;
  };

  chord.groups = function() {
    if (!groups) relayout();
    return groups;
  };

  return chord;
};
// A rudimentary force layout using Gauss-Seidel.
d3.layout.force = function() {
  var force = {},
      event = d3.dispatch("tick"),
      size = [1, 1],
      drag,
      alpha,
      friction = .9,
      linkDistance = d3_layout_forceLinkDistance,
      linkStrength = d3_layout_forceLinkStrength,
      charge = -30,
      gravity = .1,
      theta = .8,
      interval,
      nodes = [],
      links = [],
      distances,
      strengths,
      charges;

  function repulse(node) {
    return function(quad, x1, y1, x2, y2) {
      if (quad.point !== node) {
        var dx = quad.cx - node.x,
            dy = quad.cy - node.y,
            dn = 1 / Math.sqrt(dx * dx + dy * dy);

        /* Barnes-Hut criterion. */
        if ((x2 - x1) * dn < theta) {
          var k = quad.charge * dn * dn;
          node.px -= dx * k;
          node.py -= dy * k;
          return true;
        }

        if (quad.point && isFinite(dn)) {
          var k = quad.pointCharge * dn * dn;
          node.px -= dx * k;
          node.py -= dy * k;
        }
      }
      return !quad.charge;
    };
  }

  function tick() {
    var n = nodes.length,
        m = links.length,
        q,
        i, // current index
        o, // current object
        s, // current source
        t, // current target
        l, // current distance
        k, // current force
        x, // x-distance
        y; // y-distance

    // gauss-seidel relaxation for links
    for (i = 0; i < m; ++i) {
      o = links[i];
      s = o.source;
      t = o.target;
      x = t.x - s.x;
      y = t.y - s.y;
      if (l = (x * x + y * y)) {
        l = alpha * strengths[i] * ((l = Math.sqrt(l)) - distances[i]) / l;
        x *= l;
        y *= l;
        t.x -= x * (k = s.weight / (t.weight + s.weight));
        t.y -= y * k;
        s.x += x * (k = 1 - k);
        s.y += y * k;
      }
    }

    // apply gravity forces
    if (k = alpha * gravity) {
      x = size[0] / 2;
      y = size[1] / 2;
      i = -1; if (k) while (++i < n) {
        o = nodes[i];
        o.x += (x - o.x) * k;
        o.y += (y - o.y) * k;
      }
    }

    // compute quadtree center of mass and apply charge forces
    if (charge) {
      d3_layout_forceAccumulate(q = d3.geom.quadtree(nodes), alpha, charges);
      i = -1; while (++i < n) {
        if (!(o = nodes[i]).fixed) {
          q.visit(repulse(o));
        }
      }
    }

    // position verlet integration
    i = -1; while (++i < n) {
      o = nodes[i];
      if (o.fixed) {
        o.x = o.px;
        o.y = o.py;
      } else {
        o.x -= (o.px - (o.px = o.x)) * friction;
        o.y -= (o.py - (o.py = o.y)) * friction;
      }
    }

    event.tick({type: "tick", alpha: alpha});

    // simulated annealing, basically
    return (alpha *= .99) < .005;
  }

  force.nodes = function(x) {
    if (!arguments.length) return nodes;
    nodes = x;
    return force;
  };

  force.links = function(x) {
    if (!arguments.length) return links;
    links = x;
    return force;
  };

  force.size = function(x) {
    if (!arguments.length) return size;
    size = x;
    return force;
  };

  force.linkDistance = function(x) {
    if (!arguments.length) return linkDistance;
    linkDistance = d3.functor(x);
    return force;
  };

  // For backwards-compatibility.
  force.distance = force.linkDistance;

  force.linkStrength = function(x) {
    if (!arguments.length) return linkStrength;
    linkStrength = d3.functor(x);
    return force;
  };

  force.friction = function(x) {
    if (!arguments.length) return friction;
    friction = x;
    return force;
  };

  force.charge = function(x) {
    if (!arguments.length) return charge;
    charge = typeof x === "function" ? x : +x;
    return force;
  };

  force.gravity = function(x) {
    if (!arguments.length) return gravity;
    gravity = x;
    return force;
  };

  force.theta = function(x) {
    if (!arguments.length) return theta;
    theta = x;
    return force;
  };

  force.start = function() {
    var i,
        j,
        n = nodes.length,
        m = links.length,
        w = size[0],
        h = size[1],
        neighbors,
        o;

    for (i = 0; i < n; ++i) {
      (o = nodes[i]).index = i;
      o.weight = 0;
    }

    distances = [];
    strengths = [];
    for (i = 0; i < m; ++i) {
      o = links[i];
      if (typeof o.source == "number") o.source = nodes[o.source];
      if (typeof o.target == "number") o.target = nodes[o.target];
      distances[i] = linkDistance.call(this, o, i);
      strengths[i] = linkStrength.call(this, o, i);
      ++o.source.weight;
      ++o.target.weight;
    }

    for (i = 0; i < n; ++i) {
      o = nodes[i];
      if (isNaN(o.x)) o.x = position("x", w);
      if (isNaN(o.y)) o.y = position("y", h);
      if (isNaN(o.px)) o.px = o.x;
      if (isNaN(o.py)) o.py = o.y;
    }

    charges = [];
    if (typeof charge === "function") {
      for (i = 0; i < n; ++i) {
        charges[i] = +charge.call(this, nodes[i], i);
      }
    } else {
      for (i = 0; i < n; ++i) {
        charges[i] = charge;
      }
    }

    // initialize node position based on first neighbor
    function position(dimension, size) {
      var neighbors = neighbor(i),
          j = -1,
          m = neighbors.length,
          x;
      while (++j < m) if (!isNaN(x = neighbors[j][dimension])) return x;
      return Math.random() * size;
    }

    // initialize neighbors lazily
    function neighbor() {
      if (!neighbors) {
        neighbors = [];
        for (j = 0; j < n; ++j) {
          neighbors[j] = [];
        }
        for (j = 0; j < m; ++j) {
          var o = links[j];
          neighbors[o.source.index].push(o.target);
          neighbors[o.target.index].push(o.source);
        }
      }
      return neighbors[i];
    }

    return force.resume();
  };

  force.resume = function() {
    alpha = .1;
    d3.timer(tick);
    return force;
  };

  force.stop = function() {
    alpha = 0;
    return force;
  };

  // use `node.call(force.drag)` to make nodes draggable
  force.drag = function() {
    if (!drag) drag = d3.behavior.drag()
        .origin(Object)
        .on("dragstart", dragstart)
        .on("drag", d3_layout_forceDrag)
        .on("dragend", d3_layout_forceDragEnd);

    this.on("mouseover.force", d3_layout_forceDragOver)
        .on("mouseout.force", d3_layout_forceDragOut)
        .call(drag);
  };

  function dragstart(d) {
    d3_layout_forceDragOver(d3_layout_forceDragNode = d);
    d3_layout_forceDragForce = force;
  }

  return d3.rebind(force, event, "on");
};

var d3_layout_forceDragForce,
    d3_layout_forceDragNode;

function d3_layout_forceDragOver(d) {
  d.fixed |= 2;
}

function d3_layout_forceDragOut(d) {
  if (d !== d3_layout_forceDragNode) d.fixed &= 1;
}

function d3_layout_forceDragEnd() {
  d3_layout_forceDrag();
  d3_layout_forceDragNode.fixed &= 1;
  d3_layout_forceDragForce = d3_layout_forceDragNode = null;
}

function d3_layout_forceDrag() {
  d3_layout_forceDragNode.px = d3.event.x;
  d3_layout_forceDragNode.py = d3.event.y;
  d3_layout_forceDragForce.resume(); // restart annealing
}

function d3_layout_forceAccumulate(quad, alpha, charges) {
  var cx = 0,
      cy = 0;
  quad.charge = 0;
  if (!quad.leaf) {
    var nodes = quad.nodes,
        n = nodes.length,
        i = -1,
        c;
    while (++i < n) {
      c = nodes[i];
      if (c == null) continue;
      d3_layout_forceAccumulate(c, alpha, charges);
      quad.charge += c.charge;
      cx += c.charge * c.cx;
      cy += c.charge * c.cy;
    }
  }
  if (quad.point) {
    // jitter internal nodes that are coincident
    if (!quad.leaf) {
      quad.point.x += Math.random() - .5;
      quad.point.y += Math.random() - .5;
    }
    var k = alpha * charges[quad.point.index];
    quad.charge += quad.pointCharge = k;
    cx += k * quad.point.x;
    cy += k * quad.point.y;
  }
  quad.cx = cx / quad.charge;
  quad.cy = cy / quad.charge;
}

function d3_layout_forceLinkDistance(link) {
  return 20;
}

function d3_layout_forceLinkStrength(link) {
  return 1;
}
d3.layout.partition = function() {
  var hierarchy = d3.layout.hierarchy(),
      size = [1, 1]; // width, height

  function position(node, x, dx, dy) {
    var children = node.children;
    node.x = x;
    node.y = node.depth * dy;
    node.dx = dx;
    node.dy = dy;
    if (children && (n = children.length)) {
      var i = -1,
          n,
          c,
          d;
      dx = node.value ? dx / node.value : 0;
      while (++i < n) {
        position(c = children[i], x, d = c.value * dx, dy);
        x += d;
      }
    }
  }

  function depth(node) {
    var children = node.children,
        d = 0;
    if (children && (n = children.length)) {
      var i = -1,
          n;
      while (++i < n) d = Math.max(d, depth(children[i]));
    }
    return 1 + d;
  }

  function partition(d, i) {
    var nodes = hierarchy.call(this, d, i);
    position(nodes[0], 0, size[0], size[1] / depth(nodes[0]));
    return nodes;
  }

  partition.size = function(x) {
    if (!arguments.length) return size;
    size = x;
    return partition;
  };

  return d3_layout_hierarchyRebind(partition, hierarchy);
};
d3.layout.pie = function() {
  var value = Number,
      sort = d3_layout_pieSortByValue,
      startAngle = 0,
      endAngle = 2 * Math.PI;

  function pie(data, i) {

    // Compute the numeric values for each data element.
    var values = data.map(function(d, i) { return +value.call(pie, d, i); });

    // Compute the start angle.
    var a = +(typeof startAngle === "function"
        ? startAngle.apply(this, arguments)
        : startAngle);

    // Compute the angular scale factor: from value to radians.
    var k = ((typeof endAngle === "function"
        ? endAngle.apply(this, arguments)
        : endAngle) - startAngle)
        / d3.sum(values);

    // Optionally sort the data.
    var index = d3.range(data.length);
    if (sort != null) index.sort(sort === d3_layout_pieSortByValue
        ? function(i, j) { return values[j] - values[i]; }
        : function(i, j) { return sort(data[i], data[j]); });

    // Compute the arcs!
    // They are stored in the original data's order.
    var arcs = [];
    index.forEach(function(i) {
      arcs[i] = {
        data: data[i],
        value: d = values[i],
        startAngle: a,
        endAngle: a += d * k
      };
    });
    return arcs;
  }

  /**
   * Specifies the value function *x*, which returns a nonnegative numeric value
   * for each datum. The default value function is `Number`. The value function
   * is passed two arguments: the current datum and the current index.
   */
  pie.value = function(x) {
    if (!arguments.length) return value;
    value = x;
    return pie;
  };

  /**
   * Specifies a sort comparison operator *x*. The comparator is passed two data
   * elements from the data array, a and b; it returns a negative value if a is
   * less than b, a positive value if a is greater than b, and zero if a equals
   * b.
   */
  pie.sort = function(x) {
    if (!arguments.length) return sort;
    sort = x;
    return pie;
  };

  /**
   * Specifies the overall start angle of the pie chart. Defaults to 0. The
   * start angle can be specified either as a constant or as a function; in the
   * case of a function, it is evaluated once per array (as opposed to per
   * element).
   */
  pie.startAngle = function(x) {
    if (!arguments.length) return startAngle;
    startAngle = x;
    return pie;
  };

  /**
   * Specifies the overall end angle of the pie chart. Defaults to 2π. The
   * end angle can be specified either as a constant or as a function; in the
   * case of a function, it is evaluated once per array (as opposed to per
   * element).
   */
  pie.endAngle = function(x) {
    if (!arguments.length) return endAngle;
    endAngle = x;
    return pie;
  };

  return pie;
};

var d3_layout_pieSortByValue = {};
// data is two-dimensional array of x,y; we populate y0
d3.layout.stack = function() {
  var values = Object,
      order = d3_layout_stackOrders["default"],
      offset = d3_layout_stackOffsets["zero"],
      out = d3_layout_stackOut,
      x = d3_layout_stackX,
      y = d3_layout_stackY;

  function stack(data, index) {

    // Convert series to canonical two-dimensional representation.
    var series = data.map(function(d, i) {
      return values.call(stack, d, i);
    });

    // Convert each series to canonical [[x,y]] representation.
    var points = series.map(function(d, i) {
      return d.map(function(v, i) {
        return [x.call(stack, v, i), y.call(stack, v, i)];
      });
    });

    // Compute the order of series, and permute them.
    var orders = order.call(stack, points, index);
    series = d3.permute(series, orders);
    points = d3.permute(points, orders);

    // Compute the baseline…
    var offsets = offset.call(stack, points, index);

    // And propagate it to other series.
    var n = series.length,
        m = series[0].length,
        i,
        j,
        o;
    for (j = 0; j < m; ++j) {
      out.call(stack, series[0][j], o = offsets[j], points[0][j][1]);
      for (i = 1; i < n; ++i) {
        out.call(stack, series[i][j], o += points[i - 1][j][1], points[i][j][1]);
      }
    }

    return data;
  }

  stack.values = function(x) {
    if (!arguments.length) return values;
    values = x;
    return stack;
  };

  stack.order = function(x) {
    if (!arguments.length) return order;
    order = typeof x === "function" ? x : d3_layout_stackOrders[x];
    return stack;
  };

  stack.offset = function(x) {
    if (!arguments.length) return offset;
    offset = typeof x === "function" ? x : d3_layout_stackOffsets[x];
    return stack;
  };

  stack.x = function(z) {
    if (!arguments.length) return x;
    x = z;
    return stack;
  };

  stack.y = function(z) {
    if (!arguments.length) return y;
    y = z;
    return stack;
  };

  stack.out = function(z) {
    if (!arguments.length) return out;
    out = z;
    return stack;
  };

  return stack;
}

function d3_layout_stackX(d) {
  return d.x;
}

function d3_layout_stackY(d) {
  return d.y;
}

function d3_layout_stackOut(d, y0, y) {
  d.y0 = y0;
  d.y = y;
}

var d3_layout_stackOrders = {

  "inside-out": function(data) {
    var n = data.length,
        i,
        j,
        max = data.map(d3_layout_stackMaxIndex),
        sums = data.map(d3_layout_stackReduceSum),
        index = d3.range(n).sort(function(a, b) { return max[a] - max[b]; }),
        top = 0,
        bottom = 0,
        tops = [],
        bottoms = [];
    for (i = 0; i < n; ++i) {
      j = index[i];
      if (top < bottom) {
        top += sums[j];
        tops.push(j);
      } else {
        bottom += sums[j];
        bottoms.push(j);
      }
    }
    return bottoms.reverse().concat(tops);
  },

  "reverse": function(data) {
    return d3.range(data.length).reverse();
  },

  "default": function(data) {
    return d3.range(data.length);
  }

};

var d3_layout_stackOffsets = {

  "silhouette": function(data) {
    var n = data.length,
        m = data[0].length,
        sums = [],
        max = 0,
        i,
        j,
        o,
        y0 = [];
    for (j = 0; j < m; ++j) {
      for (i = 0, o = 0; i < n; i++) o += data[i][j][1];
      if (o > max) max = o;
      sums.push(o);
    }
    for (j = 0; j < m; ++j) {
      y0[j] = (max - sums[j]) / 2;
    }
    return y0;
  },

  "wiggle": function(data) {
    var n = data.length,
        x = data[0],
        m = x.length,
        max = 0,
        i,
        j,
        k,
        s1,
        s2,
        s3,
        dx,
        o,
        o0,
        y0 = [];
    y0[0] = o = o0 = 0;
    for (j = 1; j < m; ++j) {
      for (i = 0, s1 = 0; i < n; ++i) s1 += data[i][j][1];
      for (i = 0, s2 = 0, dx = x[j][0] - x[j - 1][0]; i < n; ++i) {
        for (k = 0, s3 = (data[i][j][1] - data[i][j - 1][1]) / (2 * dx); k < i; ++k) {
          s3 += (data[k][j][1] - data[k][j - 1][1]) / dx;
        }
        s2 += s3 * data[i][j][1];
      }
      y0[j] = o -= s1 ? s2 / s1 * dx : 0;
      if (o < o0) o0 = o;
    }
    for (j = 0; j < m; ++j) y0[j] -= o0;
    return y0;
  },

  "expand": function(data) {
    var n = data.length,
        m = data[0].length,
        k = 1 / n,
        i,
        j,
        o,
        y0 = [];
    for (j = 0; j < m; ++j) {
      for (i = 0, o = 0; i < n; i++) o += data[i][j][1];
      if (o) for (i = 0; i < n; i++) data[i][j][1] /= o;
      else for (i = 0; i < n; i++) data[i][j][1] = k;
    }
    for (j = 0; j < m; ++j) y0[j] = 0;
    return y0;
  },

  "zero": function(data) {
    var j = -1,
        m = data[0].length,
        y0 = [];
    while (++j < m) y0[j] = 0;
    return y0;
  }

};

function d3_layout_stackMaxIndex(array) {
  var i = 1,
      j = 0,
      v = array[0][1],
      k,
      n = array.length;
  for (; i < n; ++i) {
    if ((k = array[i][1]) > v) {
      j = i;
      v = k;
    }
  }
  return j;
}

function d3_layout_stackReduceSum(d) {
  return d.reduce(d3_layout_stackSum, 0);
}

function d3_layout_stackSum(p, d) {
  return p + d[1];
}
d3.layout.histogram = function() {
  var frequency = true,
      valuer = Number,
      ranger = d3_layout_histogramRange,
      binner = d3_layout_histogramBinSturges;

  function histogram(data, i) {
    var bins = [],
        values = data.map(valuer, this),
        range = ranger.call(this, values, i),
        thresholds = binner.call(this, range, values, i),
        bin,
        i = -1,
        n = values.length,
        m = thresholds.length - 1,
        k = frequency ? 1 : 1 / n,
        x;

    // Initialize the bins.
    while (++i < m) {
      bin = bins[i] = [];
      bin.dx = thresholds[i + 1] - (bin.x = thresholds[i]);
      bin.y = 0;
    }

    // Fill the bins, ignoring values outside the range.
    i = -1; while(++i < n) {
      x = values[i];
      if ((x >= range[0]) && (x <= range[1])) {
        bin = bins[d3.bisect(thresholds, x, 1, m) - 1];
        bin.y += k;
        bin.push(data[i]);
      }
    }

    return bins;
  }

  // Specifies how to extract a value from the associated data. The default
  // value function is `Number`, which is equivalent to the identity function.
  histogram.value = function(x) {
    if (!arguments.length) return valuer;
    valuer = x;
    return histogram;
  };

  // Specifies the range of the histogram. Values outside the specified range
  // will be ignored. The argument `x` may be specified either as a two-element
  // array representing the minimum and maximum value of the range, or as a
  // function that returns the range given the array of values and the current
  // index `i`. The default range is the extent (minimum and maximum) of the
  // values.
  histogram.range = function(x) {
    if (!arguments.length) return ranger;
    ranger = d3.functor(x);
    return histogram;
  };

  // Specifies how to bin values in the histogram. The argument `x` may be
  // specified as a number, in which case the range of values will be split
  // uniformly into the given number of bins. Or, `x` may be an array of
  // threshold values, defining the bins; the specified array must contain the
  // rightmost (upper) value, thus specifying n + 1 values for n bins. Or, `x`
  // may be a function which is evaluated, being passed the range, the array of
  // values, and the current index `i`, returning an array of thresholds. The
  // default bin function will divide the values into uniform bins using
  // Sturges' formula.
  histogram.bins = function(x) {
    if (!arguments.length) return binner;
    binner = typeof x === "number"
        ? function(range) { return d3_layout_histogramBinFixed(range, x); }
        : d3.functor(x);
    return histogram;
  };

  // Specifies whether the histogram's `y` value is a count (frequency) or a
  // probability (density). The default value is true.
  histogram.frequency = function(x) {
    if (!arguments.length) return frequency;
    frequency = !!x;
    return histogram;
  };

  return histogram;
};

function d3_layout_histogramBinSturges(range, values) {
  return d3_layout_histogramBinFixed(range, Math.ceil(Math.log(values.length) / Math.LN2 + 1));
}

function d3_layout_histogramBinFixed(range, n) {
  var x = -1,
      b = +range[0],
      m = (range[1] - b) / n,
      f = [];
  while (++x <= n) f[x] = m * x + b;
  return f;
}

function d3_layout_histogramRange(values) {
  return [d3.min(values), d3.max(values)];
}
d3.layout.hierarchy = function() {
  var sort = d3_layout_hierarchySort,
      children = d3_layout_hierarchyChildren,
      value = d3_layout_hierarchyValue;

  // Recursively compute the node depth and value.
  // Also converts the data representation into a standard hierarchy structure.
  function recurse(data, depth, nodes) {
    var childs = children.call(hierarchy, data, depth),
        node = d3_layout_hierarchyInline ? data : {data: data};
    node.depth = depth;
    nodes.push(node);
    if (childs && (n = childs.length)) {
      var i = -1,
          n,
          c = node.children = [],
          v = 0,
          j = depth + 1;
      while (++i < n) {
        d = recurse(childs[i], j, nodes);
        d.parent = node;
        c.push(d);
        v += d.value;
      }
      if (sort) c.sort(sort);
      if (value) node.value = v;
    } else if (value) {
      node.value = +value.call(hierarchy, data, depth) || 0;
    }
    return node;
  }

  // Recursively re-evaluates the node value.
  function revalue(node, depth) {
    var children = node.children,
        v = 0;
    if (children && (n = children.length)) {
      var i = -1,
          n,
          j = depth + 1;
      while (++i < n) v += revalue(children[i], j);
    } else if (value) {
      v = +value.call(hierarchy, d3_layout_hierarchyInline ? node : node.data, depth) || 0;
    }
    if (value) node.value = v;
    return v;
  }

  function hierarchy(d) {
    var nodes = [];
    recurse(d, 0, nodes);
    return nodes;
  }

  hierarchy.sort = function(x) {
    if (!arguments.length) return sort;
    sort = x;
    return hierarchy;
  };

  hierarchy.children = function(x) {
    if (!arguments.length) return children;
    children = x;
    return hierarchy;
  };

  hierarchy.value = function(x) {
    if (!arguments.length) return value;
    value = x;
    return hierarchy;
  };

  // Re-evaluates the `value` property for the specified hierarchy.
  hierarchy.revalue = function(root) {
    revalue(root, 0);
    return root;
  };

  return hierarchy;
};

// A method assignment helper for hierarchy subclasses.
function d3_layout_hierarchyRebind(object, hierarchy) {
  d3.rebind(object, hierarchy, "sort", "children", "value");

  // Add an alias for links, for convenience.
  object.links = d3_layout_hierarchyLinks;

  // If the new API is used, enabling inlining.
  object.nodes = function(d) {
    d3_layout_hierarchyInline = true;
    return (object.nodes = object)(d);
  };

  return object;
}

function d3_layout_hierarchyChildren(d) {
  return d.children;
}

function d3_layout_hierarchyValue(d) {
  return d.value;
}

function d3_layout_hierarchySort(a, b) {
  return b.value - a.value;
}

// Returns an array source+target objects for the specified nodes.
function d3_layout_hierarchyLinks(nodes) {
  return d3.merge(nodes.map(function(parent) {
    return (parent.children || []).map(function(child) {
      return {source: parent, target: child};
    });
  }));
}

// For backwards-compatibility, don't enable inlining by default.
var d3_layout_hierarchyInline = false;
d3.layout.pack = function() {
  var hierarchy = d3.layout.hierarchy().sort(d3_layout_packSort),
      size = [1, 1];

  function pack(d, i) {
    var nodes = hierarchy.call(this, d, i),
        root = nodes[0];

    // Recursively compute the layout.
    root.x = 0;
    root.y = 0;
    d3_layout_packTree(root);

    // Scale the layout to fit the requested size.
    var w = size[0],
        h = size[1],
        k = 1 / Math.max(2 * root.r / w, 2 * root.r / h);
    d3_layout_packTransform(root, w / 2, h / 2, k);

    return nodes;
  }

  pack.size = function(x) {
    if (!arguments.length) return size;
    size = x;
    return pack;
  };

  return d3_layout_hierarchyRebind(pack, hierarchy);
};

function d3_layout_packSort(a, b) {
  return a.value - b.value;
}

function d3_layout_packInsert(a, b) {
  var c = a._pack_next;
  a._pack_next = b;
  b._pack_prev = a;
  b._pack_next = c;
  c._pack_prev = b;
}

function d3_layout_packSplice(a, b) {
  a._pack_next = b;
  b._pack_prev = a;
}

function d3_layout_packIntersects(a, b) {
  var dx = b.x - a.x,
      dy = b.y - a.y,
      dr = a.r + b.r;
  return dr * dr - dx * dx - dy * dy > .001; // within epsilon
}

function d3_layout_packCircle(nodes) {
  var xMin = Infinity,
      xMax = -Infinity,
      yMin = Infinity,
      yMax = -Infinity,
      n = nodes.length,
      a, b, c, j, k;

  function bound(node) {
    xMin = Math.min(node.x - node.r, xMin);
    xMax = Math.max(node.x + node.r, xMax);
    yMin = Math.min(node.y - node.r, yMin);
    yMax = Math.max(node.y + node.r, yMax);
  }

  // Create node links.
  nodes.forEach(d3_layout_packLink);

  // Create first node.
  a = nodes[0];
  a.x = -a.r;
  a.y = 0;
  bound(a);

  // Create second node.
  if (n > 1) {
    b = nodes[1];
    b.x = b.r;
    b.y = 0;
    bound(b);

    // Create third node and build chain.
    if (n > 2) {
      c = nodes[2];
      d3_layout_packPlace(a, b, c);
      bound(c);
      d3_layout_packInsert(a, c);
      a._pack_prev = c;
      d3_layout_packInsert(c, b);
      b = a._pack_next;

      // Now iterate through the rest.
      for (var i = 3; i < n; i++) {
        d3_layout_packPlace(a, b, c = nodes[i]);

        // Search for the closest intersection.
        var isect = 0, s1 = 1, s2 = 1;
        for (j = b._pack_next; j !== b; j = j._pack_next, s1++) {
          if (d3_layout_packIntersects(j, c)) {
            isect = 1;
            break;
          }
        }
        if (isect == 1) {
          for (k = a._pack_prev; k !== j._pack_prev; k = k._pack_prev, s2++) {
            if (d3_layout_packIntersects(k, c)) {
              break;
            }
          }
        }

        // Update node chain.
        if (isect) {
          if (s1 < s2 || (s1 == s2 && b.r < a.r)) d3_layout_packSplice(a, b = j);
          else d3_layout_packSplice(a = k, b);
          i--;
        } else {
          d3_layout_packInsert(a, c);
          b = c;
          bound(c);
        }
      }
    }
  }

  // Re-center the circles and return the encompassing radius.
  var cx = (xMin + xMax) / 2,
      cy = (yMin + yMax) / 2,
      cr = 0;
  for (var i = 0; i < n; i++) {
    var node = nodes[i];
    node.x -= cx;
    node.y -= cy;
    cr = Math.max(cr, node.r + Math.sqrt(node.x * node.x + node.y * node.y));
  }

  // Remove node links.
  nodes.forEach(d3_layout_packUnlink);

  return cr;
}

function d3_layout_packLink(node) {
  node._pack_next = node._pack_prev = node;
}

function d3_layout_packUnlink(node) {
  delete node._pack_next;
  delete node._pack_prev;
}

function d3_layout_packTree(node) {
  var children = node.children;
  if (children && children.length) {
    children.forEach(d3_layout_packTree);
    node.r = d3_layout_packCircle(children);
  } else {
    node.r = Math.sqrt(node.value);
  }
}

function d3_layout_packTransform(node, x, y, k) {
  var children = node.children;
  node.x = (x += k * node.x);
  node.y = (y += k * node.y);
  node.r *= k;
  if (children) {
    var i = -1, n = children.length;
    while (++i < n) d3_layout_packTransform(children[i], x, y, k);
  }
}

function d3_layout_packPlace(a, b, c) {
  var db = a.r + c.r,
      dx = b.x - a.x,
      dy = b.y - a.y;
  if (db && (dx || dy)) {
    var da = b.r + c.r,
        dc = Math.sqrt(dx * dx + dy * dy),
        cos = Math.max(-1, Math.min(1, (db * db + dc * dc - da * da) / (2 * db * dc))),
        theta = Math.acos(cos),
        x = cos * (db /= dc),
        y = Math.sin(theta) * db;
    c.x = a.x + x * dx + y * dy;
    c.y = a.y + x * dy - y * dx;
  } else {
    c.x = a.x + db;
    c.y = a.y;
  }
}
// Implements a hierarchical layout using the cluster (or dendogram) algorithm.
d3.layout.cluster = function() {
  var hierarchy = d3.layout.hierarchy().sort(null).value(null),
      separation = d3_layout_treeSeparation,
      size = [1, 1]; // width, height

  function cluster(d, i) {
    var nodes = hierarchy.call(this, d, i),
        root = nodes[0],
        previousNode,
        x = 0,
        kx,
        ky;

    // First walk, computing the initial x & y values.
    d3_layout_treeVisitAfter(root, function(node) {
      var children = node.children;
      if (children && children.length) {
        node.x = d3_layout_clusterX(children);
        node.y = d3_layout_clusterY(children);
      } else {
        node.x = previousNode ? x += separation(node, previousNode) : 0;
        node.y = 0;
        previousNode = node;
      }
    });

    // Compute the left-most, right-most, and depth-most nodes for extents.
    var left = d3_layout_clusterLeft(root),
        right = d3_layout_clusterRight(root),
        x0 = left.x - separation(left, right) / 2,
        x1 = right.x + separation(right, left) / 2;

    // Second walk, normalizing x & y to the desired size.
    d3_layout_treeVisitAfter(root, function(node) {
      node.x = (node.x - x0) / (x1 - x0) * size[0];
      node.y = (1 - (root.y ? node.y / root.y : 1)) * size[1];
    });

    return nodes;
  }

  cluster.separation = function(x) {
    if (!arguments.length) return separation;
    separation = x;
    return cluster;
  };

  cluster.size = function(x) {
    if (!arguments.length) return size;
    size = x;
    return cluster;
  };

  return d3_layout_hierarchyRebind(cluster, hierarchy);
};

function d3_layout_clusterY(children) {
  return 1 + d3.max(children, function(child) {
    return child.y;
  });
}

function d3_layout_clusterX(children) {
  return children.reduce(function(x, child) {
    return x + child.x;
  }, 0) / children.length;
}

function d3_layout_clusterLeft(node) {
  var children = node.children;
  return children && children.length ? d3_layout_clusterLeft(children[0]) : node;
}

function d3_layout_clusterRight(node) {
  var children = node.children, n;
  return children && (n = children.length) ? d3_layout_clusterRight(children[n - 1]) : node;
}
// Node-link tree diagram using the Reingold-Tilford "tidy" algorithm
d3.layout.tree = function() {
  var hierarchy = d3.layout.hierarchy().sort(null).value(null),
      separation = d3_layout_treeSeparation,
      size = [1, 1]; // width, height

  function tree(d, i) {
    var nodes = hierarchy.call(this, d, i),
        root = nodes[0];

    function firstWalk(node, previousSibling) {
      var children = node.children,
          layout = node._tree;
      if (children && (n = children.length)) {
        var n,
            firstChild = children[0],
            previousChild,
            ancestor = firstChild,
            child,
            i = -1;
        while (++i < n) {
          child = children[i];
          firstWalk(child, previousChild);
          ancestor = apportion(child, previousChild, ancestor);
          previousChild = child;
        }
        d3_layout_treeShift(node);
        var midpoint = .5 * (firstChild._tree.prelim + child._tree.prelim);
        if (previousSibling) {
          layout.prelim = previousSibling._tree.prelim + separation(node, previousSibling);
          layout.mod = layout.prelim - midpoint;
        } else {
          layout.prelim = midpoint;
        }
      } else {
        if (previousSibling) {
          layout.prelim = previousSibling._tree.prelim + separation(node, previousSibling);
        }
      }
    }

    function secondWalk(node, x) {
      node.x = node._tree.prelim + x;
      var children = node.children;
      if (children && (n = children.length)) {
        var i = -1,
            n;
        x += node._tree.mod;
        while (++i < n) {
          secondWalk(children[i], x);
        }
      }
    }

    function apportion(node, previousSibling, ancestor) {
      if (previousSibling) {
        var vip = node,
            vop = node,
            vim = previousSibling,
            vom = node.parent.children[0],
            sip = vip._tree.mod,
            sop = vop._tree.mod,
            sim = vim._tree.mod,
            som = vom._tree.mod,
            shift;
        while (vim = d3_layout_treeRight(vim), vip = d3_layout_treeLeft(vip), vim && vip) {
          vom = d3_layout_treeLeft(vom);
          vop = d3_layout_treeRight(vop);
          vop._tree.ancestor = node;
          shift = vim._tree.prelim + sim - vip._tree.prelim - sip + separation(vim, vip);
          if (shift > 0) {
            d3_layout_treeMove(d3_layout_treeAncestor(vim, node, ancestor), node, shift);
            sip += shift;
            sop += shift;
          }
          sim += vim._tree.mod;
          sip += vip._tree.mod;
          som += vom._tree.mod;
          sop += vop._tree.mod;
        }
        if (vim && !d3_layout_treeRight(vop)) {
          vop._tree.thread = vim;
          vop._tree.mod += sim - sop;
        }
        if (vip && !d3_layout_treeLeft(vom)) {
          vom._tree.thread = vip;
          vom._tree.mod += sip - som;
          ancestor = node;
        }
      }
      return ancestor;
    }

    // Initialize temporary layout variables.
    d3_layout_treeVisitAfter(root, function(node, previousSibling) {
      node._tree = {
        ancestor: node,
        prelim: 0,
        mod: 0,
        change: 0,
        shift: 0,
        number: previousSibling ? previousSibling._tree.number + 1 : 0
      };
    });

    // Compute the layout using Buchheim et al.'s algorithm.
    firstWalk(root);
    secondWalk(root, -root._tree.prelim);

    // Compute the left-most, right-most, and depth-most nodes for extents.
    var left = d3_layout_treeSearch(root, d3_layout_treeLeftmost),
        right = d3_layout_treeSearch(root, d3_layout_treeRightmost),
        deep = d3_layout_treeSearch(root, d3_layout_treeDeepest),
        x0 = left.x - separation(left, right) / 2,
        x1 = right.x + separation(right, left) / 2,
        y1 = deep.depth || 1;

    // Clear temporary layout variables; transform x and y.
    d3_layout_treeVisitAfter(root, function(node) {
      node.x = (node.x - x0) / (x1 - x0) * size[0];
      node.y = node.depth / y1 * size[1];
      delete node._tree;
    });

    return nodes;
  }

  tree.separation = function(x) {
    if (!arguments.length) return separation;
    separation = x;
    return tree;
  };

  tree.size = function(x) {
    if (!arguments.length) return size;
    size = x;
    return tree;
  };

  return d3_layout_hierarchyRebind(tree, hierarchy);
};

function d3_layout_treeSeparation(a, b) {
  return a.parent == b.parent ? 1 : 2;
}

// function d3_layout_treeSeparationRadial(a, b) {
//   return (a.parent == b.parent ? 1 : 2) / a.depth;
// }

function d3_layout_treeLeft(node) {
  var children = node.children;
  return children && children.length ? children[0] : node._tree.thread;
}

function d3_layout_treeRight(node) {
  var children = node.children,
      n;
  return children && (n = children.length) ? children[n - 1] : node._tree.thread;
}

function d3_layout_treeSearch(node, compare) {
  var children = node.children;
  if (children && (n = children.length)) {
    var child,
        n,
        i = -1;
    while (++i < n) {
      if (compare(child = d3_layout_treeSearch(children[i], compare), node) > 0) {
        node = child;
      }
    }
  }
  return node;
}

function d3_layout_treeRightmost(a, b) {
  return a.x - b.x;
}

function d3_layout_treeLeftmost(a, b) {
  return b.x - a.x;
}

function d3_layout_treeDeepest(a, b) {
  return a.depth - b.depth;
}

function d3_layout_treeVisitAfter(node, callback) {
  function visit(node, previousSibling) {
    var children = node.children;
    if (children && (n = children.length)) {
      var child,
          previousChild = null,
          i = -1,
          n;
      while (++i < n) {
        child = children[i];
        visit(child, previousChild);
        previousChild = child;
      }
    }
    callback(node, previousSibling);
  }
  visit(node, null);
}

function d3_layout_treeShift(node) {
  var shift = 0,
      change = 0,
      children = node.children,
      i = children.length,
      child;
  while (--i >= 0) {
    child = children[i]._tree;
    child.prelim += shift;
    child.mod += shift;
    shift += child.shift + (change += child.change);
  }
}

function d3_layout_treeMove(ancestor, node, shift) {
  ancestor = ancestor._tree;
  node = node._tree;
  var change = shift / (node.number - ancestor.number);
  ancestor.change += change;
  node.change -= change;
  node.shift += shift;
  node.prelim += shift;
  node.mod += shift;
}

function d3_layout_treeAncestor(vim, node, ancestor) {
  return vim._tree.ancestor.parent == node.parent
      ? vim._tree.ancestor
      : ancestor;
}
// Squarified Treemaps by Mark Bruls, Kees Huizing, and Jarke J. van Wijk
// Modified to support a target aspect ratio by Jeff Heer
d3.layout.treemap = function() {
  var hierarchy = d3.layout.hierarchy(),
      round = Math.round,
      size = [1, 1], // width, height
      padding = null,
      pad = d3_layout_treemapPadNull,
      sticky = false,
      stickies,
      ratio = 0.5 * (1 + Math.sqrt(5)); // golden ratio

  // Compute the area for each child based on value & scale.
  function scale(children, k) {
    var i = -1,
        n = children.length,
        child,
        area;
    while (++i < n) {
      area = (child = children[i]).value * (k < 0 ? 0 : k);
      child.area = isNaN(area) || area <= 0 ? 0 : area;
    }
  }

  // Recursively arranges the specified node's children into squarified rows.
  function squarify(node) {
    var children = node.children;
    if (children && children.length) {
      var rect = pad(node),
          row = [],
          remaining = children.slice(), // copy-on-write
          child,
          best = Infinity, // the best row score so far
          score, // the current row score
          u = Math.min(rect.dx, rect.dy), // initial orientation
          n;
      scale(remaining, rect.dx * rect.dy / node.value);
      row.area = 0;
      while ((n = remaining.length) > 0) {
        row.push(child = remaining[n - 1]);
        row.area += child.area;
        if ((score = worst(row, u)) <= best) { // continue with this orientation
          remaining.pop();
          best = score;
        } else { // abort, and try a different orientation
          row.area -= row.pop().area;
          position(row, u, rect, false);
          u = Math.min(rect.dx, rect.dy);
          row.length = row.area = 0;
          best = Infinity;
        }
      }
      if (row.length) {
        position(row, u, rect, true);
        row.length = row.area = 0;
      }
      children.forEach(squarify);
    }
  }

  // Recursively resizes the specified node's children into existing rows.
  // Preserves the existing layout!
  function stickify(node) {
    var children = node.children;
    if (children && children.length) {
      var rect = pad(node),
          remaining = children.slice(), // copy-on-write
          child,
          row = [];
      scale(remaining, rect.dx * rect.dy / node.value);
      row.area = 0;
      while (child = remaining.pop()) {
        row.push(child);
        row.area += child.area;
        if (child.z != null) {
          position(row, child.z ? rect.dx : rect.dy, rect, !remaining.length);
          row.length = row.area = 0;
        }
      }
      children.forEach(stickify);
    }
  }

  // Computes the score for the specified row, as the worst aspect ratio.
  function worst(row, u) {
    var s = row.area,
        r,
        rmax = 0,
        rmin = Infinity,
        i = -1,
        n = row.length;
    while (++i < n) {
      if (!(r = row[i].area)) continue;
      if (r < rmin) rmin = r;
      if (r > rmax) rmax = r;
    }
    s *= s;
    u *= u;
    return s
        ? Math.max((u * rmax * ratio) / s, s / (u * rmin * ratio))
        : Infinity;
  }

  // Positions the specified row of nodes. Modifies `rect`.
  function position(row, u, rect, flush) {
    var i = -1,
        n = row.length,
        x = rect.x,
        y = rect.y,
        v = u ? round(row.area / u) : 0,
        o;
    if (u == rect.dx) { // horizontal subdivision
      if (flush || v > rect.dy) v = rect.dy; // over+underflow
      while (++i < n) {
        o = row[i];
        o.x = x;
        o.y = y;
        o.dy = v;
        x += o.dx = Math.min(rect.x + rect.dx - x, v ? round(o.area / v) : 0);
      }
      o.z = true;
      o.dx += rect.x + rect.dx - x; // rounding error
      rect.y += v;
      rect.dy -= v;
    } else { // vertical subdivision
      if (flush || v > rect.dx) v = rect.dx; // over+underflow
      while (++i < n) {
        o = row[i];
        o.x = x;
        o.y = y;
        o.dx = v;
        y += o.dy = Math.min(rect.y + rect.dy - y, v ? round(o.area / v) : 0);
      }
      o.z = false;
      o.dy += rect.y + rect.dy - y; // rounding error
      rect.x += v;
      rect.dx -= v;
    }
  }

  function treemap(d) {
    var nodes = stickies || hierarchy(d),
        root = nodes[0];
    root.x = 0;
    root.y = 0;
    root.dx = size[0];
    root.dy = size[1];
    if (stickies) hierarchy.revalue(root);
    scale([root], root.dx * root.dy / root.value);
    (stickies ? stickify : squarify)(root);
    if (sticky) stickies = nodes;
    return nodes;
  }

  treemap.size = function(x) {
    if (!arguments.length) return size;
    size = x;
    return treemap;
  };

  treemap.padding = function(x) {
    if (!arguments.length) return padding;

    function padFunction(node) {
      var p = x.call(treemap, node, node.depth);
      return p == null
          ? d3_layout_treemapPadNull(node)
          : d3_layout_treemapPad(node, typeof p === "number" ? [p, p, p, p] : p);
    }

    function padConstant(node) {
      return d3_layout_treemapPad(node, x);
    }

    var type;
    pad = (padding = x) == null ? d3_layout_treemapPadNull
        : (type = typeof x) === "function" ? padFunction
        : type === "number" ? (x = [x, x, x, x], padConstant)
        : padConstant;
    return treemap;
  };

  treemap.round = function(x) {
    if (!arguments.length) return round != Number;
    round = x ? Math.round : Number;
    return treemap;
  };

  treemap.sticky = function(x) {
    if (!arguments.length) return sticky;
    sticky = x;
    stickies = null;
    return treemap;
  };

  treemap.ratio = function(x) {
    if (!arguments.length) return ratio;
    ratio = x;
    return treemap;
  };

  return d3_layout_hierarchyRebind(treemap, hierarchy);
};

function d3_layout_treemapPadNull(node) {
  return {x: node.x, y: node.y, dx: node.dx, dy: node.dy};
}

function d3_layout_treemapPad(node, padding) {
  var x = node.x + padding[3],
      y = node.y + padding[0],
      dx = node.dx - padding[1] - padding[3],
      dy = node.dy - padding[0] - padding[2];
  if (dx < 0) { x += dx / 2; dx = 0; }
  if (dy < 0) { y += dy / 2; dy = 0; }
  return {x: x, y: y, dx: dx, dy: dy};
}
})();



/*!
 * jQuery Form Plugin
 * version: 3.09 (16-APR-2012)
 * @requires jQuery v1.3.2 or later
 *
 * Examples and documentation at: http://malsup.com/jquery/form/
 * Project repository: https://github.com/malsup/form
 * Dual licensed under the MIT and GPL licenses:
 *    http://malsup.github.com/mit-license.txt
 *    http://malsup.github.com/gpl-license-v2.txt
 */
/*global ActiveXObject alert */

;(function($) {
"use strict";

/*
    Usage Note:
    -----------
    Do not use both ajaxSubmit and ajaxForm on the same form.  These
    functions are mutually exclusive.  Use ajaxSubmit if you want
    to bind your own submit handler to the form.  For example,

    $(document).ready(function() {
        $('#myForm').on('submit', function(e) {
            e.preventDefault(); // <-- important
            $(this).ajaxSubmit({
                target: '#output'
            });
        });
    });

    Use ajaxForm when you want the plugin to manage all the event binding
    for you.  For example,

    $(document).ready(function() {
        $('#myForm').ajaxForm({
            target: '#output'
        });
    });
    
    You can also use ajaxForm with delegation (requires jQuery v1.7+), so the
    form does not have to exist when you invoke ajaxForm:

    $('#myForm').ajaxForm({
        delegation: true,
        target: '#output'
    });
    
    When using ajaxForm, the ajaxSubmit function will be invoked for you
    at the appropriate time.
*/

/**
 * Feature detection
 */
var feature = {};
feature.fileapi = $("<input type='file'/>").get(0).files !== undefined;
feature.formdata = window.FormData !== undefined;

/**
 * ajaxSubmit() provides a mechanism for immediately submitting
 * an HTML form using AJAX.
 */
$.fn.ajaxSubmit = function(options) {
    /*jshint scripturl:true */

    // fast fail if nothing selected (http://dev.jquery.com/ticket/2752)
    if (!this.length) {
        log('ajaxSubmit: skipping submit process - no element selected');
        return this;
    }
    
    var method, action, url, $form = this;

    if (typeof options == 'function') {
        options = { success: options };
    }

    method = this.attr('method');
    action = this.attr('action');
    url = (typeof action === 'string') ? $.trim(action) : '';
    url = url || window.location.href || '';
    if (url) {
        // clean url (don't include hash vaue)
        url = (url.match(/^([^#]+)/)||[])[1];
    }

    options = $.extend(true, {
        url:  url,
        success: $.ajaxSettings.success,
        type: method || 'GET',
        iframeSrc: /^https/i.test(window.location.href || '') ? 'javascript:false' : 'about:blank'
    }, options);

    // hook for manipulating the form data before it is extracted;
    // convenient for use with rich editors like tinyMCE or FCKEditor
    var veto = {};
    this.trigger('form-pre-serialize', [this, options, veto]);
    if (veto.veto) {
        log('ajaxSubmit: submit vetoed via form-pre-serialize trigger');
        return this;
    }

    // provide opportunity to alter form data before it is serialized
    if (options.beforeSerialize && options.beforeSerialize(this, options) === false) {
        log('ajaxSubmit: submit aborted via beforeSerialize callback');
        return this;
    }

    var traditional = options.traditional;
    if ( traditional === undefined ) {
        traditional = $.ajaxSettings.traditional;
    }
    
    var elements = [];
    var qx, a = this.formToArray(options.semantic, elements);
    if (options.data) {
        options.extraData = options.data;
        qx = $.param(options.data, traditional);
    }

    // give pre-submit callback an opportunity to abort the submit
    if (options.beforeSubmit && options.beforeSubmit(a, this, options) === false) {
        log('ajaxSubmit: submit aborted via beforeSubmit callback');
        return this;
    }

    // fire vetoable 'validate' event
    this.trigger('form-submit-validate', [a, this, options, veto]);
    if (veto.veto) {
        log('ajaxSubmit: submit vetoed via form-submit-validate trigger');
        return this;
    }

    var q = $.param(a, traditional);
    if (qx) {
        q = ( q ? (q + '&' + qx) : qx );
    }    
    if (options.type.toUpperCase() == 'GET') {
        options.url += (options.url.indexOf('?') >= 0 ? '&' : '?') + q;
        options.data = null;  // data is null for 'get'
    }
    else {
        options.data = q; // data is the query string for 'post'
    }

    var callbacks = [];
    if (options.resetForm) {
        callbacks.push(function() { $form.resetForm(); });
    }
    if (options.clearForm) {
        callbacks.push(function() { $form.clearForm(options.includeHidden); });
    }

    // perform a load on the target only if dataType is not provided
    if (!options.dataType && options.target) {
        var oldSuccess = options.success || function(){};
        callbacks.push(function(data) {
            var fn = options.replaceTarget ? 'replaceWith' : 'html';
            $(options.target)[fn](data).each(oldSuccess, arguments);
        });
    }
    else if (options.success) {
        callbacks.push(options.success);
    }

    options.success = function(data, status, xhr) { // jQuery 1.4+ passes xhr as 3rd arg
        var context = options.context || options;    // jQuery 1.4+ supports scope context 
        for (var i=0, max=callbacks.length; i < max; i++) {
            callbacks[i].apply(context, [data, status, xhr || $form, $form]);
        }
    };

    // are there files to upload?
    var fileInputs = $('input:file:enabled[value]', this); // [value] (issue #113)
    var hasFileInputs = fileInputs.length > 0;
    var mp = 'multipart/form-data';
    var multipart = ($form.attr('enctype') == mp || $form.attr('encoding') == mp);

    var fileAPI = feature.fileapi && feature.formdata;
    log("fileAPI :" + fileAPI);
    var shouldUseFrame = (hasFileInputs || multipart) && !fileAPI;

    // options.iframe allows user to force iframe mode
    // 06-NOV-09: now defaulting to iframe mode if file input is detected
    if (options.iframe !== false && (options.iframe || shouldUseFrame)) {
        // hack to fix Safari hang (thanks to Tim Molendijk for this)
        // see:  http://groups.google.com/group/jquery-dev/browse_thread/thread/36395b7ab510dd5d
        if (options.closeKeepAlive) {
            $.get(options.closeKeepAlive, function() {
                fileUploadIframe(a);
            });
        }
          else {
            fileUploadIframe(a);
          }
    }
    else if ((hasFileInputs || multipart) && fileAPI) {
        fileUploadXhr(a);
    }
    else {
        $.ajax(options);
    }

    // clear element array
    for (var k=0; k < elements.length; k++)
        elements[k] = null;

    // fire 'notify' event
    this.trigger('form-submit-notify', [this, options]);
    return this;

     // XMLHttpRequest Level 2 file uploads (big hat tip to francois2metz)
    function fileUploadXhr(a) {
        var formdata = new FormData();

        for (var i=0; i < a.length; i++) {
            formdata.append(a[i].name, a[i].value);
        }

        if (options.extraData) {
            for (var p in options.extraData)
                if (options.extraData.hasOwnProperty(p))
                    formdata.append(p, options.extraData[p]);
        }

        options.data = null;

        var s = $.extend(true, {}, $.ajaxSettings, options, {
            contentType: false,
            processData: false,
            cache: false,
            type: 'POST'
        });
        
        if (options.uploadProgress) {
            // workaround because jqXHR does not expose upload property
            s.xhr = function() {
                var xhr = jQuery.ajaxSettings.xhr();
                if (xhr.upload) {
                    xhr.upload.onprogress = function(event) {
                        var percent = 0;
                        var position = event.loaded || event.position; /*event.position is deprecated*/
                        var total = event.total;
                        if (event.lengthComputable) {
                            percent = Math.ceil(position / total * 100);
                        }
                        options.uploadProgress(event, position, total, percent);
                    };
                }
                return xhr;
            };
        }

        s.data = null;
          var beforeSend = s.beforeSend;
          s.beforeSend = function(xhr, o) {
              o.data = formdata;
            if(beforeSend)
                beforeSend.call(o, xhr, options);
        };
        $.ajax(s);
    }

    // private function for handling file uploads (hat tip to YAHOO!)
    function fileUploadIframe(a) {
        var form = $form[0], el, i, s, g, id, $io, io, xhr, sub, n, timedOut, timeoutHandle;
        var useProp = !!$.fn.prop;

        if ($(':input[name=submit],:input[id=submit]', form).length) {
            // if there is an input with a name or id of 'submit' then we won't be
            // able to invoke the submit fn on the form (at least not x-browser)
            alert('Error: Form elements must not have name or id of "submit".');
            return;
        }
        
        if (a) {
            // ensure that every serialized input is still enabled
            for (i=0; i < elements.length; i++) {
                el = $(elements[i]);
                if ( useProp )
                    el.prop('disabled', false);
                else
                    el.removeAttr('disabled');
            }
        }

        s = $.extend(true, {}, $.ajaxSettings, options);
        s.context = s.context || s;
        id = 'jqFormIO' + (new Date().getTime());
        if (s.iframeTarget) {
            $io = $(s.iframeTarget);
            n = $io.attr('name');
            if (!n)
                 $io.attr('name', id);
            else
                id = n;
        }
        else {
            $io = $('<iframe name="' + id + '" src="'+ s.iframeSrc +'" />');
            $io.css({ position: 'absolute', top: '-1000px', left: '-1000px' });
        }
        io = $io[0];


        xhr = { // mock object
            aborted: 0,
            responseText: null,
            responseXML: null,
            status: 0,
            statusText: 'n/a',
            getAllResponseHeaders: function() {},
            getResponseHeader: function() {},
            setRequestHeader: function() {},
            abort: function(status) {
                var e = (status === 'timeout' ? 'timeout' : 'aborted');
                log('aborting upload... ' + e);
                this.aborted = 1;
                $io.attr('src', s.iframeSrc); // abort op in progress
                xhr.error = e;
                if (s.error)
                    s.error.call(s.context, xhr, e, status);
                if (g)
                    $.event.trigger("ajaxError", [xhr, s, e]);
                if (s.complete)
                    s.complete.call(s.context, xhr, e);
            }
        };

        g = s.global;
        // trigger ajax global events so that activity/block indicators work like normal
        if (g && 0 === $.active++) {
            $.event.trigger("ajaxStart");
        }
        if (g) {
            $.event.trigger("ajaxSend", [xhr, s]);
        }

        if (s.beforeSend && s.beforeSend.call(s.context, xhr, s) === false) {
            if (s.global) {
                $.active--;
            }
            return;
        }
        if (xhr.aborted) {
            return;
        }

        // add submitting element to data if we know it
        sub = form.clk;
        if (sub) {
            n = sub.name;
            if (n && !sub.disabled) {
                s.extraData = s.extraData || {};
                s.extraData[n] = sub.value;
                if (sub.type == "image") {
                    s.extraData[n+'.x'] = form.clk_x;
                    s.extraData[n+'.y'] = form.clk_y;
                }
            }
        }
        
        var CLIENT_TIMEOUT_ABORT = 1;
        var SERVER_ABORT = 2;

        function getDoc(frame) {
            var doc = frame.contentWindow ? frame.contentWindow.document : frame.contentDocument ? frame.contentDocument : frame.document;
            return doc;
        }
        
        // Rails CSRF hack (thanks to Yvan Barthelemy)
        var csrf_token = $('meta[name=csrf-token]').attr('content');
        var csrf_param = $('meta[name=csrf-param]').attr('content');
        if (csrf_param && csrf_token) {
            s.extraData = s.extraData || {};
            s.extraData[csrf_param] = csrf_token;
        }

        // take a breath so that pending repaints get some cpu time before the upload starts
        function doSubmit() {
            // make sure form attrs are set
            var t = $form.attr('target'), a = $form.attr('action');

            // update form attrs in IE friendly way
            form.setAttribute('target',id);
            if (!method) {
                form.setAttribute('method', 'POST');
            }
            if (a != s.url) {
                form.setAttribute('action', s.url);
            }

            // ie borks in some cases when setting encoding
            if (! s.skipEncodingOverride && (!method || /post/i.test(method))) {
                $form.attr({
                    encoding: 'multipart/form-data',
                    enctype:  'multipart/form-data'
                });
            }

            // support timout
            if (s.timeout) {
                timeoutHandle = setTimeout(function() { timedOut = true; cb(CLIENT_TIMEOUT_ABORT); }, s.timeout);
            }
            
            // look for server aborts
            function checkState() {
                try {
                    var state = getDoc(io).readyState;
                    log('state = ' + state);
                    if (state && state.toLowerCase() == 'uninitialized')
                        setTimeout(checkState,50);
                }
                catch(e) {
                    log('Server abort: ' , e, ' (', e.name, ')');
                    cb(SERVER_ABORT);
                    if (timeoutHandle)
                        clearTimeout(timeoutHandle);
                    timeoutHandle = undefined;
                }
            }

            // add "extra" data to form if provided in options
            var extraInputs = [];
            try {
                if (s.extraData) {
                    for (var n in s.extraData) {
                        if (s.extraData.hasOwnProperty(n)) {
                            extraInputs.push(
                                $('<input type="hidden" name="'+n+'">').attr('value',s.extraData[n])
                                    .appendTo(form)[0]);
                        }
                    }
                }

                if (!s.iframeTarget) {
                    // add iframe to doc and submit the form
                    $io.appendTo('body');
                    if (io.attachEvent)
                        io.attachEvent('onload', cb);
                    else
                        io.addEventListener('load', cb, false);
                }
                setTimeout(checkState,15);
                form.submit();
            }
            finally {
                // reset attrs and remove "extra" input elements
                form.setAttribute('action',a);
                if(t) {
                    form.setAttribute('target', t);
                } else {
                    $form.removeAttr('target');
                }
                $(extraInputs).remove();
            }
        }

        if (s.forceSync) {
            doSubmit();
        }
        else {
            setTimeout(doSubmit, 10); // this lets dom updates render
        }

        var data, doc, domCheckCount = 50, callbackProcessed;

        function cb(e) {
            if (xhr.aborted || callbackProcessed) {
                return;
            }
            try {
                doc = getDoc(io);
            }
            catch(ex) {
                log('cannot access response document: ', ex);
                e = SERVER_ABORT;
            }
            if (e === CLIENT_TIMEOUT_ABORT && xhr) {
                xhr.abort('timeout');
                return;
            }
            else if (e == SERVER_ABORT && xhr) {
                xhr.abort('server abort');
                return;
            }

            if (!doc || doc.location.href == s.iframeSrc) {
                // response not received yet
                if (!timedOut)
                    return;
            }
            if (io.detachEvent)
                io.detachEvent('onload', cb);
            else    
                io.removeEventListener('load', cb, false);

            var status = 'success', errMsg;
            try {
                if (timedOut) {
                    throw 'timeout';
                }

                var isXml = s.dataType == 'xml' || doc.XMLDocument || $.isXMLDoc(doc);
                log('isXml='+isXml);
                if (!isXml && window.opera && (doc.body === null || !doc.body.innerHTML)) {
                    if (--domCheckCount) {
                        // in some browsers (Opera) the iframe DOM is not always traversable when
                        // the onload callback fires, so we loop a bit to accommodate
                        log('requeing onLoad callback, DOM not available');
                        setTimeout(cb, 250);
                        return;
                    }
                    // let this fall through because server response could be an empty document
                    //log('Could not access iframe DOM after mutiple tries.');
                    //throw 'DOMException: not available';
                }

                //log('response detected');
                var docRoot = doc.body ? doc.body : doc.documentElement;
                xhr.responseText = docRoot ? docRoot.innerHTML : null;
                xhr.responseXML = doc.XMLDocument ? doc.XMLDocument : doc;
                if (isXml)
                    s.dataType = 'xml';
                xhr.getResponseHeader = function(header){
                    var headers = {'content-type': s.dataType};
                    return headers[header];
                };
                // support for XHR 'status' & 'statusText' emulation :
                if (docRoot) {
                    xhr.status = Number( docRoot.getAttribute('status') ) || xhr.status;
                    xhr.statusText = docRoot.getAttribute('statusText') || xhr.statusText;
                }

                var dt = (s.dataType || '').toLowerCase();
                var scr = /(json|script|text)/.test(dt);
                if (scr || s.textarea) {
                    // see if user embedded response in textarea
                    var ta = doc.getElementsByTagName('textarea')[0];
                    if (ta) {
                        xhr.responseText = ta.value;
                        // support for XHR 'status' & 'statusText' emulation :
                        xhr.status = Number( ta.getAttribute('status') ) || xhr.status;
                        xhr.statusText = ta.getAttribute('statusText') || xhr.statusText;
                    }
                    else if (scr) {
                        // account for browsers injecting pre around json response
                        var pre = doc.getElementsByTagName('pre')[0];
                        var b = doc.getElementsByTagName('body')[0];
                        if (pre) {
                            xhr.responseText = pre.textContent ? pre.textContent : pre.innerText;
                        }
                        else if (b) {
                            xhr.responseText = b.textContent ? b.textContent : b.innerText;
                        }
                    }
                }
                else if (dt == 'xml' && !xhr.responseXML && xhr.responseText) {
                    xhr.responseXML = toXml(xhr.responseText);
                }

                try {
                    data = httpData(xhr, dt, s);
                }
                catch (e) {
                    status = 'parsererror';
                    xhr.error = errMsg = (e || status);
                }
            }
            catch (e) {
                log('error caught: ',e);
                status = 'error';
                xhr.error = errMsg = (e || status);
            }

            if (xhr.aborted) {
                log('upload aborted');
                status = null;
            }

            if (xhr.status) { // we've set xhr.status
                status = (xhr.status >= 200 && xhr.status < 300 || xhr.status === 304) ? 'success' : 'error';
            }

            // ordering of these callbacks/triggers is odd, but that's how $.ajax does it
            if (status === 'success') {
                if (s.success)
                    s.success.call(s.context, data, 'success', xhr);
                if (g)
                    $.event.trigger("ajaxSuccess", [xhr, s]);
            }
            else if (status) {
                if (errMsg === undefined)
                    errMsg = xhr.statusText;
                if (s.error)
                    s.error.call(s.context, xhr, status, errMsg);
                if (g)
                    $.event.trigger("ajaxError", [xhr, s, errMsg]);
            }

            if (g)
                $.event.trigger("ajaxComplete", [xhr, s]);

            if (g && ! --$.active) {
                $.event.trigger("ajaxStop");
            }

            if (s.complete)
                s.complete.call(s.context, xhr, status);

            callbackProcessed = true;
            if (s.timeout)
                clearTimeout(timeoutHandle);

            // clean up
            setTimeout(function() {
                if (!s.iframeTarget)
                    $io.remove();
                xhr.responseXML = null;
            }, 100);
        }

        var toXml = $.parseXML || function(s, doc) { // use parseXML if available (jQuery 1.5+)
            if (window.ActiveXObject) {
                doc = new ActiveXObject('Microsoft.XMLDOM');
                doc.async = 'false';
                doc.loadXML(s);
            }
            else {
                doc = (new DOMParser()).parseFromString(s, 'text/xml');
            }
            return (doc && doc.documentElement && doc.documentElement.nodeName != 'parsererror') ? doc : null;
        };
        var parseJSON = $.parseJSON || function(s) {
            /*jslint evil:true */
            return window['eval']('(' + s + ')');
        };

        var httpData = function( xhr, type, s ) { // mostly lifted from jq1.4.4

            var ct = xhr.getResponseHeader('content-type') || '',
                xml = type === 'xml' || !type && ct.indexOf('xml') >= 0,
                data = xml ? xhr.responseXML : xhr.responseText;

            if (xml && data.documentElement.nodeName === 'parsererror') {
                if ($.error)
                    $.error('parsererror');
            }
            if (s && s.dataFilter) {
                data = s.dataFilter(data, type);
            }
            if (typeof data === 'string') {
                if (type === 'json' || !type && ct.indexOf('json') >= 0) {
                    data = parseJSON(data);
                } else if (type === "script" || !type && ct.indexOf("javascript") >= 0) {
                    $.globalEval(data);
                }
            }
            return data;
        };
    }
};

/**
 * ajaxForm() provides a mechanism for fully automating form submission.
 *
 * The advantages of using this method instead of ajaxSubmit() are:
 *
 * 1: This method will include coordinates for <input type="image" /> elements (if the element
 *    is used to submit the form).
 * 2. This method will include the submit element's name/value data (for the element that was
 *    used to submit the form).
 * 3. This method binds the submit() method to the form for you.
 *
 * The options argument for ajaxForm works exactly as it does for ajaxSubmit.  ajaxForm merely
 * passes the options argument along after properly binding events for submit elements and
 * the form itself.
 */
$.fn.ajaxForm = function(options) {
    options = options || {};
    options.delegation = options.delegation && $.isFunction($.fn.on);
    
    // in jQuery 1.3+ we can fix mistakes with the ready state
    if (!options.delegation && this.length === 0) {
        var o = { s: this.selector, c: this.context };
        if (!$.isReady && o.s) {
            log('DOM not ready, queuing ajaxForm');
            $(function() {
                $(o.s,o.c).ajaxForm(options);
            });
            return this;
        }
        // is your DOM ready?  http://docs.jquery.com/Tutorials:Introducing_$(document).ready()
        log('terminating; zero elements found by selector' + ($.isReady ? '' : ' (DOM not ready)'));
        return this;
    }

    if ( options.delegation ) {
        $(document)
            .off('submit.form-plugin', this.selector, doAjaxSubmit)
            .off('click.form-plugin', this.selector, captureSubmittingElement)
            .on('submit.form-plugin', this.selector, options, doAjaxSubmit)
            .on('click.form-plugin', this.selector, options, captureSubmittingElement);
        return this;
    }

    return this.ajaxFormUnbind()
        .bind('submit.form-plugin', options, doAjaxSubmit)
        .bind('click.form-plugin', options, captureSubmittingElement);
};

// private event handlers    
function doAjaxSubmit(e) {
    /*jshint validthis:true */
    var options = e.data;
    if (!e.isDefaultPrevented()) { // if event has been canceled, don't proceed
        e.preventDefault();
        $(this).ajaxSubmit(options);
    }
}
    
function captureSubmittingElement(e) {
    /*jshint validthis:true */
    var target = e.target;
    var $el = $(target);
    if (!($el.is(":submit,input:image"))) {
        // is this a child element of the submit el?  (ex: a span within a button)
        var t = $el.closest(':submit');
        if (t.length === 0) {
            return;
        }
        target = t[0];
    }
    var form = this;
    form.clk = target;
    if (target.type == 'image') {
        if (e.offsetX !== undefined) {
            form.clk_x = e.offsetX;
            form.clk_y = e.offsetY;
        } else if (typeof $.fn.offset == 'function') {
            var offset = $el.offset();
            form.clk_x = e.pageX - offset.left;
            form.clk_y = e.pageY - offset.top;
        } else {
            form.clk_x = e.pageX - target.offsetLeft;
            form.clk_y = e.pageY - target.offsetTop;
        }
    }
    // clear form vars
    setTimeout(function() { form.clk = form.clk_x = form.clk_y = null; }, 100);
}


// ajaxFormUnbind unbinds the event handlers that were bound by ajaxForm
$.fn.ajaxFormUnbind = function() {
    return this.unbind('submit.form-plugin click.form-plugin');
};

/**
 * formToArray() gathers form element data into an array of objects that can
 * be passed to any of the following ajax functions: $.get, $.post, or load.
 * Each object in the array has both a 'name' and 'value' property.  An example of
 * an array for a simple login form might be:
 *
 * [ { name: 'username', value: 'jresig' }, { name: 'password', value: 'secret' } ]
 *
 * It is this array that is passed to pre-submit callback functions provided to the
 * ajaxSubmit() and ajaxForm() methods.
 */
$.fn.formToArray = function(semantic, elements) {
    var a = [];
    if (this.length === 0) {
        return a;
    }

    var form = this[0];
    var els = semantic ? form.getElementsByTagName('*') : form.elements;
    if (!els) {
        return a;
    }

    var i,j,n,v,el,max,jmax;
    for(i=0, max=els.length; i < max; i++) {
        el = els[i];
        n = el.name;
        if (!n) {
            continue;
        }

        if (semantic && form.clk && el.type == "image") {
            // handle image inputs on the fly when semantic == true
            if(!el.disabled && form.clk == el) {
                a.push({name: n, value: $(el).val(), type: el.type });
                a.push({name: n+'.x', value: form.clk_x}, {name: n+'.y', value: form.clk_y});
            }
            continue;
        }

        v = $.fieldValue(el, true);
        if (v && v.constructor == Array) {
            if (elements) 
                elements.push(el);
            for(j=0, jmax=v.length; j < jmax; j++) {
                a.push({name: n, value: v[j]});
            }
        }
        else if (feature.fileapi && el.type == 'file' && !el.disabled) {
            if (elements) 
                elements.push(el);
            var files = el.files;
            if (files.length) {
                for (j=0; j < files.length; j++) {
                    a.push({name: n, value: files[j], type: el.type});
                }
            }
            else {
                // #180
                a.push({ name: n, value: '', type: el.type });
            }
        }
        else if (v !== null && typeof v != 'undefined') {
            if (elements) 
                elements.push(el);
            a.push({name: n, value: v, type: el.type, required: el.required});
        }
    }

    if (!semantic && form.clk) {
        // input type=='image' are not found in elements array! handle it here
        var $input = $(form.clk), input = $input[0];
        n = input.name;
        if (n && !input.disabled && input.type == 'image') {
            a.push({name: n, value: $input.val()});
            a.push({name: n+'.x', value: form.clk_x}, {name: n+'.y', value: form.clk_y});
        }
    }
    return a;
};

/**
 * Serializes form data into a 'submittable' string. This method will return a string
 * in the format: name1=value1&amp;name2=value2
 */
$.fn.formSerialize = function(semantic) {
    //hand off to jQuery.param for proper encoding
    return $.param(this.formToArray(semantic));
};

/**
 * Serializes all field elements in the jQuery object into a query string.
 * This method will return a string in the format: name1=value1&amp;name2=value2
 */
$.fn.fieldSerialize = function(successful) {
    var a = [];
    this.each(function() {
        var n = this.name;
        if (!n) {
            return;
        }
        var v = $.fieldValue(this, successful);
        if (v && v.constructor == Array) {
            for (var i=0,max=v.length; i < max; i++) {
                a.push({name: n, value: v[i]});
            }
        }
        else if (v !== null && typeof v != 'undefined') {
            a.push({name: this.name, value: v});
        }
    });
    //hand off to jQuery.param for proper encoding
    return $.param(a);
};

/**
 * Returns the value(s) of the element in the matched set.  For example, consider the following form:
 *
 *  <form><fieldset>
 *      <input name="A" type="text" />
 *      <input name="A" type="text" />
 *      <input name="B" type="checkbox" value="B1" />
 *      <input name="B" type="checkbox" value="B2"/>
 *      <input name="C" type="radio" value="C1" />
 *      <input name="C" type="radio" value="C2" />
 *  </fieldset></form>
 *
 *  var v = $(':text').fieldValue();
 *  // if no values are entered into the text inputs
 *  v == ['','']
 *  // if values entered into the text inputs are 'foo' and 'bar'
 *  v == ['foo','bar']
 *
 *  var v = $(':checkbox').fieldValue();
 *  // if neither checkbox is checked
 *  v === undefined
 *  // if both checkboxes are checked
 *  v == ['B1', 'B2']
 *
 *  var v = $(':radio').fieldValue();
 *  // if neither radio is checked
 *  v === undefined
 *  // if first radio is checked
 *  v == ['C1']
 *
 * The successful argument controls whether or not the field element must be 'successful'
 * (per http://www.w3.org/TR/html4/interact/forms.html#successful-controls).
 * The default value of the successful argument is true.  If this value is false the value(s)
 * for each element is returned.
 *
 * Note: This method *always* returns an array.  If no valid value can be determined the
 *    array will be empty, otherwise it will contain one or more values.
 */
$.fn.fieldValue = function(successful) {
    for (var val=[], i=0, max=this.length; i < max; i++) {
        var el = this[i];
        var v = $.fieldValue(el, successful);
        if (v === null || typeof v == 'undefined' || (v.constructor == Array && !v.length)) {
            continue;
        }
        if (v.constructor == Array)
            $.merge(val, v);
        else
            val.push(v);
    }
    return val;
};

/**
 * Returns the value of the field element.
 */
$.fieldValue = function(el, successful) {
    var n = el.name, t = el.type, tag = el.tagName.toLowerCase();
    if (successful === undefined) {
        successful = true;
    }

    if (successful && (!n || el.disabled || t == 'reset' || t == 'button' ||
        (t == 'checkbox' || t == 'radio') && !el.checked ||
        (t == 'submit' || t == 'image') && el.form && el.form.clk != el ||
        tag == 'select' && el.selectedIndex == -1)) {
            return null;
    }

    if (tag == 'select') {
        var index = el.selectedIndex;
        if (index < 0) {
            return null;
        }
        var a = [], ops = el.options;
        var one = (t == 'select-one');
        var max = (one ? index+1 : ops.length);
        for(var i=(one ? index : 0); i < max; i++) {
            var op = ops[i];
            if (op.selected) {
                var v = op.value;
                if (!v) { // extra pain for IE...
                    v = (op.attributes && op.attributes['value'] && !(op.attributes['value'].specified)) ? op.text : op.value;
                }
                if (one) {
                    return v;
                }
                a.push(v);
            }
        }
        return a;
    }
    return $(el).val();
};

/**
 * Clears the form data.  Takes the following actions on the form's input fields:
 *  - input text fields will have their 'value' property set to the empty string
 *  - select elements will have their 'selectedIndex' property set to -1
 *  - checkbox and radio inputs will have their 'checked' property set to false
 *  - inputs of type submit, button, reset, and hidden will *not* be effected
 *  - button elements will *not* be effected
 */
$.fn.clearForm = function(includeHidden) {
    return this.each(function() {
        $('input,select,textarea', this).clearFields(includeHidden);
    });
};

/**
 * Clears the selected form elements.
 */
$.fn.clearFields = $.fn.clearInputs = function(includeHidden) {
    var re = /^(?:color|date|datetime|email|month|number|password|range|search|tel|text|time|url|week)$/i; // 'hidden' is not in this list
    return this.each(function() {
        var t = this.type, tag = this.tagName.toLowerCase();
        if (re.test(t) || tag == 'textarea') {
            this.value = '';
        }
        else if (t == 'checkbox' || t == 'radio') {
            this.checked = false;
        }
        else if (tag == 'select') {
            this.selectedIndex = -1;
        }
        else if (includeHidden) {
            // includeHidden can be the valud true, or it can be a selector string
            // indicating a special test; for example:
            //  $('#myForm').clearForm('.special:hidden')
            // the above would clean hidden inputs that have the class of 'special'
            if ( (includeHidden === true && /hidden/.test(t)) ||
                 (typeof includeHidden == 'string' && $(this).is(includeHidden)) )
                this.value = '';
        }
    });
};

/**
 * Resets the form data.  Causes all form elements to be reset to their original value.
 */
$.fn.resetForm = function() {
    return this.each(function() {
        // guard against an input with the name of 'reset'
        // note that IE reports the reset function as an 'object'
        if (typeof this.reset == 'function' || (typeof this.reset == 'object' && !this.reset.nodeType)) {
            this.reset();
        }
    });
};

/**
 * Enables or disables any matching elements.
 */
$.fn.enable = function(b) {
    if (b === undefined) {
        b = true;
    }
    return this.each(function() {
        this.disabled = !b;
    });
};

/**
 * Checks/unchecks any matching checkboxes or radio buttons and
 * selects/deselects and matching option elements.
 */
$.fn.selected = function(select) {
    if (select === undefined) {
        select = true;
    }
    return this.each(function() {
        var t = this.type;
        if (t == 'checkbox' || t == 'radio') {
            this.checked = select;
        }
        else if (this.tagName.toLowerCase() == 'option') {
            var $sel = $(this).parent('select');
            if (select && $sel[0] && $sel[0].type == 'select-one') {
                // deselect all other options
                $sel.find('option').selected(false);
            }
            this.selected = select;
        }
    });
};

// expose debug var
$.fn.ajaxSubmit.debug = false;

// helper fn for console logging
function log() {
    if (!$.fn.ajaxSubmit.debug) 
        return;
    var msg = '[jquery.form] ' + Array.prototype.join.call(arguments,'');
    if (window.console && window.console.log) {
        window.console.log(msg);
    }
    else if (window.opera && window.opera.postError) {
        window.opera.postError(msg);
    }
}

})(jQuery);
// Módulo respnsável pela criação do gráfico Basic Line do relatório
// de participação dos professores nas disciplinas do curso

var TeacherParticipationGraph = function () {
  var chart;

  // Definição do gráfico
  var options = {
    chart: {
      renderTo: '',
      defaultSeriesType: 'line'
    },
    title: {
      text: ''
    },
    xAxis:{
      title: {
        text: 'Dias'
      }
    },
    yAxis: {
      title:{
        text: 'Colaborações'
      },
      min: 0
    },
    tooltip: {
      crosshairs: true,
      shared: true
    },
    series: [{
      name: 'Quantidade de Aulas Criadas',
    }, {
      name: 'Quantidade de Postagens',
    }, {
      name: 'Quantidade de Respostas',
    }]
  };

  return {
    // Carregamento do gráfico
    load: function (graphView) {
      // Inicializa o form com o gráfico correspondente
      var graph = graphView.form.plotGraphForm(graphView.chart.renderTo);

      // Passa a função de carregamento do gráfico via JSON
      graph.loadGraph(function (json) {
        $.extend(options, graphView);

        options.series[0].data = json.lectures_created;
        options.series[1].data = json.posts;
        options.series[2].data = json.answers;

        options.xAxis.categories = json.days;
        chart = new Highcharts.Chart(options);
      });
    }
  }
};
// Objeto para carregamento do Pie Charts
var SubjectPie = function () {
    var chart;

    // Configuração padrão do pie chart
    var options = {
        chart: {
            defaultSeriesType: 'pie'
        },
        credits: {
            enabled: false
        },
        title: {
            text: ''
        },
        tooltip: {
            formatter: function() {
                return '<b>' + this.point.name + '</b>: ' + Highcharts.numberFormat( this.percentage, 1 )+ ' %';
            },
            valueDecimals: 1
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: false
                },
            }
        },
        series: [{
            type: 'pie',
            data: [
                ['Pedidos de ajuda sem resposta'],
                {
                  name: 'Pedidos de ajuda que tiveram resposta',
                  sliced: true,
                  selected: true
                },
            ]
        }]
    }

    // Carregamento do Pie Chart
    var loadPie = function (subject, div) {
      options.chart.renderTo = div;
      options.series[0].data[0] = {
        name: 'Pedidos de ajuda que tiveram resposta',
        sliced: true,
        selected: true,
        y: subject.data.helps_answered
      };
      options.series[0].data[1] = ['Pedidos de ajuda sem resposta',
        subject.data.helps_not_answered];

      new Highcharts.Chart(options);
    };

    // Retorno do objeto
    return {
      load: function (subject, div) {
        loadPie(subject, div);
      }
    }
};

// Objeto para carregamento do Bullet Charts
var SubjectBullet = function () {
    // Parametros de tamanho do bullet
    var w = 390,
        h = 107.5,
        m = [52.5, 30, 40, 20]; // top right bottom left

    var d3chart = d3.chart.bullet()
        .width(w - m[1] -m[3])
        .height(h -m[0] -m[2]);

    // Carregamento do bullet
    var loadBullet = function(data, div) {
      var vis = d3.select(div).selectAll("svg")
        .data(data)
        .enter().append("svg")
        .attr("class", "bullet")
        .attr("width", w)
        .attr("height", h)
        .append("g")
        .attr("transform", "translate(" + m[3] + "," + m[0] + ")")
        .call(d3chart);

      var title = vis.append("g")
        .attr("text-anchor", "start");

      // Subtítulo do bullet charts
      title.append("text")
        .attr("class", "subtitle-chart")
        .attr("dy", "4.5em")
        .text("Total de alunos X Total de alunos que finalizaram o módulo");

      // Atributo title para o tooltip
      d3.selectAll("rect")
        .attr("alt", "Total de alunos: " + data[0].ranges[0] +
            "<br/>Total de alunos que finalizaram o módulo: " + data[0].measures[0]);

      // Configuração default do tooltip
      $(div).find('> svg > g > rect.range').tipTip(
          { defaultPosition: "top", attribute: "alt" });
      $(div).find('> svg > g > rect.measure').tipTip(
          { defaultPosition: "top", attribute: "alt" });
    };

  // Retorno do objeto
  return {
    load: function (data, div) {
      loadBullet(data, div);
    }
  };
};

var SubjectParticipation = function () {
  var loadGraphs = function (url, token, subjects) {
    var pie = new SubjectPie();
    var bullet = new SubjectBullet();

    var divPie = "subject-participation-pie-";
    var divBullet = "#subject-participation-bullet-";

    $.ajax({
      url: url + "?oauth_token=" + token + subjects,
      method: "GET",
      dataType: 'jsonp',
      success: function (json) {
        $.each(json, function (index, object) {
          pie.load(object, divPie + object.subject_id);
          bullet.load(buildJSON (object), divBullet + object.subject_id);
        });
      }
    });
  }

  var buildJSON = function (object) {
    return [{ "ranges": [object.data.enrollments],
      "measures": [object.data.subjects_finalized],
      "markers": [object.data.enrollments] }]
  }

  return {
    load: function (url, token, subjects) {
      loadGraphs(url, token, subjects);
    }
  }
}
;
// Módulo respnsável pela criação do gráfico Stacked Area do relatório
// de participação dos alunos nas aulas da disciplina

var LectureParticipationGraph = function () {
  var chart;

  // Definição do gráfico
  var options ={
    chart: {
      renderTo: '',
      type: 'area',
      style: { lineHeight: 'normal' }
    },
    title: {
      text: ''
    },
    xAxis: {
      title: {
        text: 'Dias'
      }
    },
    yAxis: {
      title: {
        text: 'Participação'
      },
      min: 0
    },
    legend: {
      layout: 'vertical',
      x: -40
    },
    tooltip: {
      crosshairs: true,
      shared: true
    },
    plotOptions: {
      area: {
        stacking: 'normal',
        lineColor: '#666666',
        lineWidth: 1,
        marker: {
          lineWidth: 1,
          lineColor: '#666666'
        }
      }
    },
    series: [{
      name: 'Quantidade de Pedidos de Ajuda',
    }, {
      name: 'Quantidade de Postagens',
    }, {
      name: 'Quantidade de Respostas aos Pedidos de Ajuda',
    }, {
      name: 'Quantidade de Respostas às Postagens'
    }]
  }

  return {
    // Carregamento do gráfico
    load: function (graphView) {
      // Inicializa o form com o gráfico correspondente
      var graph = graphView.form.plotGraphForm(graphView.chart.renderTo);

      // Passa a função de carregamento do gráfico via JSON
      graph.loadGraph(function (json) {
        $.extend(options, graphView);

        options.series[0].data = json.helps_by_day;
        options.series[1].data = json.activities_by_day;
        options.series[2].data = json.answered_helps_by_day;
        options.series[3].data = json.answered_activities_by_day;

        options.xAxis.categories = json.days;
        chart = new Highcharts.Chart(options);
      })
    }
  }
};
// Função que trata dos elementos do form relacionado aos gráficos HighCharts,
// Manipulação dos selects das datas, checkboxs e função de submit do form
// Além de tratar eventos de erro com mensagens

$.fn.plotGraphForm = function (divRender) {
  var $this = $(this);

  // Tratamento das datas
  var timeSelected = function (period) {
    select = $("#date_"+period+"_fake__3i");
    var day = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__2i");
    var month = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__1i");
    var year = select[0].options[select[0].selectedIndex].value;
    return year + "-" + month + "-" + day;
  };

  // Validando intervalo de datas
  // O replace é para browsers que não tem o mesmo formato de String do SO,
  // e portanto retornam NaN no parse
  var validateDate = function () {
    var st = Date.parse(timeSelected("start").replace(/\-/ig, '/'));
    var en = Date.parse(timeSelected("end").replace(/\-/ig, '/'));

    return st < en;
  }

  // Tratamento dos checkboxes
  $this.find(".item-chart-check").click(function () {
    var all = $this.find("#all-check")[0];
    if (!this.checked){
      all.checked = false;
    }
    else{
      var ipts = $this.find(".item-chart-check");
      var all_checked = true;
      $.each(ipts, function () {
        if(!this.checked){
          all_checked = false
        }
      })

      if (all_checked) {
        all.checked = true;
      }
    }
  });

  $this.find("#all-check").click(function () {
    var ipts = $this.find(".item-chart-check");
    if (this.checked) {
      $.each(ipts, function () {
        this.checked = true;
      })
    }
    else{
      $.each(ipts, function () {
        this.checked = false;
      })
    }
  });

  // Função checa se mensagem de erro está ativa
  var errorExist = function (){
    return ($this.find(".error_explanation")).length
  };

  // Submissão do gráfico por AJAX
  $this.submit(function(e) {
    $this.find("#date_start").val(timeSelected("start"));
    $this.find("#date_end").val(timeSelected("end"));

    // Só submita se a data for válida
    if(!validateDate()){
      if(!errorExist()){
        $this.find('#form-problem').before('<div class="error_explanation" id="error_explanation"><h2>Ops!</h2><p>Há problemas para os seguinte(s) campo(s):</p><p class="invalid_fields">Data inicial, Data final</p></div>');
        $this.find("#date-validate").append('<ul class="errors_on_date"><li>'+"Intervalo de tempo inválido"+'</li></ul>');
      }

      // Não submita e também não chama o método live
      return false;
    }
  });

  // Requisição AJAX para carregamento do gráfico + Tratamento de erros
  $this.live("ajax:complete", function(e, xhr){
    var json = $.parseJSON(xhr.responseText);
      if(errorExist){
        $this.find(".error_explanation").remove();
        $this.find(".errors_on_date").remove();
      }

      // As requisições cross-domain não devolvem este callback,
      // sendo necessário outro callback do tipo sucess, o try catch
      // não deixa a exceção ser levantada para o usuário
      try{
        buildGraph(json);
      }
      catch(e){}
  });

  // Função de carregamento do gráfico
  var buildGraph;

  return {
    loadGraph :function (createGraph) {
      buildGraph = createGraph;

      // Primeiro carregamento do gráfico
      $this.before($("<div/>", { id: divRender }));
      $this.submit();
    }
  }
};
var StudentsTreemap = function() {
  // Configurações do layout do treemap
  var w = 748,
      h = 400,
      x = d3.scale.linear().range([0, w]),
      y = d3.scale.linear().range([0, h]),
      root,
      color = { red: d3.rgb(193,39,45),
                orange: d3.rgb(243,94,0),
                yellow: d3.rgb(255,200,0),
                green: d3.rgb(95,192,128),
                blue: d3.rgb(77,173,214),
                gray: d3.rgb(230, 230, 230) }
                // Vermelho, Laranja, Amarelo, Verde, Azul, Cinza

  // Função para preenchimento das cores da células, se grade = -1 preenchimento neutro
  var fill = function(grade) {
    if (grade === -1.0) {
      return color.gray;
    }
    else if (grade < 5.0) {
      if (grade < 3.0) {
        return color.red;
      }
      else {
        return color.orange;
      }
    }
    else {
      if(grade < 7.0) {
        return color.yellow;
      }
      else if (grade < 9.0) {
        return color.green;
      }
      else {
        return color.blue;
      };
    };
  }

  // Função que retorna o tamanho da célula proveniente do JSON
  var size = function(d) {
    return d.size;
  }

  // Função para construção padrão do JSON do treemap
  var buildJSON = function(vis, api) {
    // JSON conterá apenas um nó pai com seus filhos
    var json = {"name": "treemap",
                "children": []};

    // Para cada aluno do Space eu monto um filho padrão do treemap
    $.each(vis, function(index, object) {
      var item = {};

      // Busca o nome do aluno nos dados da API
      var user = searchUser(vis[index].user_id, api);
      if (user) {
        // Informações básicas do aluno
        item.name = user.first_name;
        item.last_name = user.last_name;
        item.id = vis[index].user_id;
      };

      // Participação + nota do aluno
      item.activities = object.data.activities;
      item.helps = object.data.helps;
      item.answered_activities = object.data.answered_activities;
      item.answered_helps = object.data.answered_helps;
      item.size = participation(object.data);
      item.grade = object.data.average_grade;

      // Adiciona novo filho ao JSON
      json.children.push(item);
    })

    // Filtra os filhos para que só mostrem os membros (alunos) da disciplina
    json.children = json.children.filter(function(child) { return child.name; });
    return json;
  }

  // Função de participação do aluno, baseado em suas atividades na Disciplina
  var participation = function(data) {
    var part = data.helps + data.activities +
      data.answered_activities + data.answered_helps;

    // O size não pode ser zero pois desconfigura o treemap
    return part + 1;
  }

  // Função que busca o nome do usuário pelo seu id
  var searchUser = function(userId, api) {
    // O retorno conterá apenas um elemento visto que um id só pode pertencer a um usuário
    var response = api.filter(function(item) {
      return item.user.id === userId;
    });

    // Se houver resposta, retorna o usuário
    if (response[0]) {
      return response[0].user;
    }

    return response;
  }

  // Função usada para remover treemap antigo, caso houver
  var removeTremap = function(div) {
    $("#"+div +" > .chart").remove();
  }

  // Função usada para remover o relatório descritivo antigo, caso houver
  var removeReportDescription = function() {
    $("#report-description").remove();
    $("#report").remove();
  }

  var fillLegend = function() {
    $("svg > #gray").css("fill", color.gray);
    $("svg > #red").css("fill", color.red);
    $("svg > #orange").css("fill", color.orange);
    $("svg > #yellow").css("fill", color.yellow);
    $("svg > #green").css("fill", color.green);
    $("svg > #blue").css("fill", color.blue);
  }

  var reportDescription = function(form, data, print, url) {
      form.before($("<span/>", { 'id': "report-description", 'class': "concave-button", 'text': "Mostrar informações detalhadas" }));
      $("#report-description").click(function(){
          $("#report").slideToggle('fast');
      });

      form.before($("<table/>", { 'id': "report", 'class': "table-report-students" }));

      var report = $("#report");
      report.hide();
      report.append($("<tbody/>", { 'id': "table-report" }));

      report.find("tbody").append($("<tr/>", { 'class': "row-head" }));
      report.find(".row-head").append($("<th/>", { 'class': "head", 'text': "Nome" }));
      report.find(".row-head").append($("<th/>", { 'class': "head", 'text': "Comentários" }));
      report.find(".row-head").append($("<th/>", { 'class': "head", 'text': "Resposta a comentários" }));
      report.find(".row-head").append($("<th/>", { 'class': "head", 'text': "Pedidos de ajuda" }));
      report.find(".row-head").append($("<th/>", { 'class': "head", 'text': "Resposta a pedidos de ajuda" }));
      report.find(".row-head").append($("<th/>", { 'class': "head", 'text': "Média dos exercícios" }));
      if (!print){
          report.find(".row-head").append($("<th/>", { 'class': "head", 'text': "Link" }));
          report.find("tbody").css('max-height', '500px').css('overflow', 'auto');
      }

      data.children.sort(compare);

      // Template
      var table = "<% _.each(_.extend(children, print), function(object){ %>" +
            "<tr class='row' id='row-<%=object.id%>'>" +
                "<td class='cell'>" +
                    "<div class='student-info'>" +
                        "<span><%=object.name + ' ' + object.last_name%></span>" +
                    "</div>" +
                "</td>" +
                "<td class='cell'>" +
                    "<span class='participation'><%=object.activities%></span>" +
                "</td>" +
                "<td class='cell'>" +
                    "<span class='participation'><%=object.answered_activities%></span>" +
                "</td>" +
                "<td class='cell'>" +
                    "<span class='participation'><%=object.helps%></span>" +
                "</td>" +
                "<td class='cell'>" +
                    "<span class='participation'><%=object.answered_activities%></span>" +
                "</td>" +
                "<td class='cell'>" +
                    "<span class='participation'><%=object.grade === -1 ? 'Não realizou' : object.grade%></span>" +
                "</td>" +
                "<% if (!print) { %>" +
                    "<td class='cell treemap-link'>" +
                        "<a href=#<%=object.id%>>no mapa</a>" +
                    "</td>" +
                "<% };%>" +
            "</tr>" +
          "<% }); %>"

      report.find("tbody").append(_.template(table, _.extend(data, { print: print })));

      $(".treemap-link").click(function(){
          $("rect").css("stroke-width", 0);
          $("g > #" + $(this).find("a")[0].href.split("#")[1]).css("stroke-width", 5).
          css("stroke", "black");
      });

      report.append($("<a/>", { 'class': "concave-button", 'text': "Imprimir", href: url }));
      report.find(".concave-button").click(function(){
          var start = timeSelected("start");
          var end = timeSelected("end");

          $(this).attr("href", url + "?date_start=" + start + "&date_end=" + end);
      });
  }

  function compare(a,b) {
      if ((a.name + " " + a.last_name).toUpperCase() < (b.name + " " + a.last_name).toUpperCase())
          return -1;
      if ((a.name + " " + a.last_name).toUpperCase() > (b.name + " " + a.last_name).toUpperCase())
          return 1;
      return 0;
  }

  var timeSelected = function(period) {
    select = $("#date_"+period+"_fake__3i");
    var day = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__2i");
    var month = select[0].options[select[0].selectedIndex].value;
    select = $("#date_"+period+"_fake__1i");
    var year = select[0].options[select[0].selectedIndex].value;
    return year + "-" + month + "-" + day;
  };

  // Função visível para a view, carregamento do treemap
  return {
   load: function(graphView) {
      //Preenche as cores da legenda
      fillLegend();

      // Inicializa o javascript do form
      var graph = graphView.form.plotGraphForm(graphView.renderTo);

      // Função para construção do treemap
      graph.loadGraph(function(jsonVis) {
        // Requisição para api precisa ser feita em busca do nome dos alunos
        $.ajax({
          url: graphView.url,
          method: "GET",
          success: function(jsonApi) {
            // remove treemap antigo
            removeTremap(graphView.renderTo);

            // Layout vazio do treemap
            var treemap = d3.layout.treemap()
              .round(false)
              .size([w, h])
              .sticky(true)
              .value(function(d) { return d.size; });

            // Div onde o treemap será carregado
            var svg = d3.select("#"+graphView.renderTo).append("div")
              .attr("class", "chart")
              .style("width", w + "px")
              .style("height", h + 54 + "px") // 54 é o tamanho da div do título do form
              .append("svg:svg")
              .attr("width", w)
              .attr("height", h)
              .append("svg:g")
              .attr("transform", "translate(.5,.5)");

            // Constrói o JSON característico do treemap usando os dados retornados das duas requisições
            root = buildJSON(jsonVis, jsonApi);

            // Carrega o treemap com o JSON montado
            var nodes = treemap.nodes(root)
              .filter(function(d) { return !d.children; });

            // Inicialização das células com seus atributos
            var cell = svg.selectAll("g")
              .data(nodes)
              .enter().append("svg:g")
              .attr("class", "cell")
              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
              .attr("alt", function(d) {
                var nota = d.grade !== -1 ? d.grade : "nenhum exercício realizado"
                return "Nome: " + d.name + " " + d.last_name
                        + "</br>Comentários: " + d.activities
                        + "</br>Pedidos de Ajuda: " + d.helps
                        + "</br>Respostas à comentários: " + d.answered_activities
                        + "</br>Respostas à pedidos de ajuda: " + d.answered_helps
                        + "</br>Nota: " + nota })

            // Cor
            cell.append("svg:rect")
              .attr("width", function(d) { return d.dx - 1; })
              .attr("height", function(d) { return d.dy - 1; })
              .attr("id", function(d) { return d.id; })
              .style("fill", function(d) { return fill(d.grade); })
              .on("click", function(){
                  $("rect").css("stroke-width", 0);
                  $(this).css("stroke-width", 5)
                  .css("stroke", "black");
              });

            // Texto
            cell.append("svg:text")
              .attr("x", function(d) { return d.dx / 2; })
              .attr("y", function(d) { return d.dy / 2; })
              .attr("dy", ".35em")
              .attr("text-anchor", "middle")
              .text(function(d) { return d.name; })
              .style("opacity", function(d) { d.w = this.getComputedTextLength(); return d.dx > d.w ? 1 : 0; });

            // Tooltip da célula
            $(".cell").tipTip({ defaultPosition: "left",
                                attribute: "alt" });

            // Relatório descritivo
            removeReportDescription();
            reportDescription(graphView.form, root, false, graphView.print);
          } // Success end
        }) // Ajax en
      }) // LoadGraph end
    }, // Load end
   print: function(graphView) {
      $("#graph-form").hide();

      // Inicializa o javascript do form
      var graph = graphView.form.plotGraphForm(graphView.renderTo);
      graph.loadGraph(function(jsonVis) {
        // Requisição para api precisa ser feita em busca do nome dos alunos
        $.ajax({
          url: graphView.url,
          method: "GET",
          success: function(jsonApi) {
            // Constrói o JSON característico do treemap usando os dados retornados das duas requisições
            root = buildJSON(jsonVis, jsonApi);

            // Relatório descritivo
            removeReportDescription();
            reportDescription(graphView.form, root, true);

            $("#report").show();
            $("#treemap-chart").hide();
            $("#report-description").hide();
            $("#report").find(".concave-button").hide();
            }
        })
      })
    } // Print end
  } // Return end
} // StudentsTreemap end
;








