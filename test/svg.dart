library bass.spec;

import 'package:hub/hub.dart';
import 'package:bass/bass.dart';

void main(){

	/*Bass.debug.enable;*/

	var box = SVG.create();
        box.f.bind(Funcs.tag('svg'));
        box.ns.sel('svg',{
          'id':'bigger',
          'width':'200px',
          '@ns':{
            '@key':'attr',
            'rocker':'domid',
          },
          'rect#1':{
            'id':"thunder",
             'width':'100px',
             'height':'50px',
              'cirle':{
                'id':'swing',
                 'width':100,
                 'height': 100
              },
          },
          'rect#2':{
              'id':"riggor"
          }
        });
        box.ns.sel('svg#2',{
          'id':'slogger',
          'width':'200px',
          '@ns:attr':{
            'rocker':'domid',
          },
          'rect#1':{
            'id':"frost",
             'width':'100px',
             'height':'50px',
              'cirle':{
                'id':'brook',
                 'width':100,
                 'height': 100
              },
          },
          'rect#2':{
              'id':"fault"
          }
        });

       box.compile();
}
