package com.visual.convolution;
import processing.core.*;
import processing.video.*;

import java.io.File;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileSystemView;


public class Video extends PApplet{
    public static int def_h=0,def_w=0;
    public static Movie mov;
    public static PGraphics pg1;
    public static String path;
    public static void main(String[] args) {
        JFileChooser jfc = new JFileChooser(FileSystemView.getFileSystemView().getHomeDirectory());
        int returnValue = jfc.showOpenDialog(null);
        if(returnValue == JFileChooser.APPROVE_OPTION){
            File selectedFile = jfc.getSelectedFile();
            path = selectedFile.getAbsolutePath();
            PApplet.main("com.visual.convolution.Video");
        }
    }

    public void settings(){
        size(200, 200);
    }

    public void setup(){
        frameRate(120);
        mov = new Movie(this, path);
        mov.loop();


        mov.read();//ugly, but is the only way to get mov size, btw...this skips a frame
        //mov.resize(400,0);
        pg1 = createGraphics(mov.width,mov.height);
        surface.setSize(mov.width*2,mov.height);

        def_w = mov.width;def_h = mov.height;
    }

    public void draw() {
        if (mov.available()) {
            mov.read();
        }
        pg1.beginDraw();
            pg1.image(mov,0,0,def_w,def_h);
        pg1.endDraw();
        image(pg1,0,0);

        pg1.beginDraw();
            decolorizeGraphics(pg1,0);
            convoluteGraphics(pg1);
        pg1.endDraw();
        image(pg1,def_w,0);

        println(frameRate);
    }

    public void convoluteGraphics(PGraphics pg){
        PGraphics temp = createGraphics(pg.width, pg.height, JAVA2D);
        temp.beginDraw();
        temp.loadPixels();
        arrayCopy(pg.pixels, temp.pixels);
        temp.updatePixels();
        temp.endDraw();

        //Good kernel guide http://setosa.io/ev/image-kernels/
        int m_size=3; //please, just odd matrix
        float[] kernel = {
                -1, -1, -1,
                -1, 8, -1,
                -1, -1, -1
        };


        int h = temp.height, w = temp.width;
        for (int i = 0; i<w;i++){
            for (int j = 0; j<h;j++){
                //i and j are the img center
                int x = i-(m_size-1)/2, y = j-(m_size-1)/2; //x,y is the corner

                PImage slice;
                slice = temp.get(x, y, m_size, m_size);

                float result = convolution(slice,kernel);
                pg.set(i, j, color(result, result, result));
            }
        }
    }

    public float convolution(PImage slice, float[] kernel){
        float val = 0;
        for (int i = 0; i<kernel.length;i++){
            val += red(slice.pixels[i]) * kernel[i];
        }
        return (val>255)?255:(val<0)?0:val;
    }

    public void decolorizeGraphics(PImage pg, int mode){
        pg.loadPixels();
        if (mode == 0){// rgb avg
            for (int i = 0 ; i < pg.pixels.length;i++){
                float avg = (red(pg.pixels[i]) + green(pg.pixels[i]) + blue(pg.pixels[i])) / 3.0f ;
                pg.pixels[i] = color(avg, avg, avg);
            }
        }else{// luma
            for (int i = 0 ; i < pg.pixels.length;i++){
                float luma = 0.299f * red(pg.pixels[i]) + 0.587f * green(pg.pixels[i]) + 0.114f * blue(pg.pixels[i]);
                pg.pixels[i] = color(luma, luma, luma);
            }
        }
        pg.updatePixels();
    }


    //We don't use this, but seems cool!!
    public void flipChannels(PImage pg){
        pg.loadPixels();
        for(int i = 0 ; i< pg.pixels.length ; i++){
            pg.pixels[i] = color(blue(pg.pixels[i]),green(pg.pixels[i]),red(pg.pixels[i]));
        }
        pg.updatePixels();
    }
}
