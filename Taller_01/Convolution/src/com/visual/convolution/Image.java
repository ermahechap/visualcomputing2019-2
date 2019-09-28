package com.visual.convolution;
import processing.core.*;

import javax.swing.*;
import javax.swing.filechooser.FileSystemView;
import java.io.File;

public class Image extends PApplet{
    public static PImage img;//img size 316x240
    public static PGraphics pg1,pg2,pg3, histGraphics;
    public static int from = 0, to = 255;
    public static String path;
    public static void main(String[] args) {
        JFileChooser jfc = new JFileChooser(FileSystemView.getFileSystemView().getHomeDirectory());
        int returnValue = jfc.showOpenDialog(null);
        if(returnValue == JFileChooser.APPROVE_OPTION){
            File selectedFile = jfc.getSelectedFile();
            path = selectedFile.getAbsolutePath();
            PApplet.main("com.visual.convolution.Image");
        }

    }

    public void settings(){
        img = loadImage(path);
        img.resize(316,0);
        size(3*img.width, img.height+200);
    }

    public void setup(){
        pg1 = createGraphics(img.width,img.height);
        pg2 = createGraphics(img.width,img.height);
        pg3 = createGraphics(img.width,img.height);
        histGraphics = createGraphics(img.width*3,200);
    }

    public void draw(){
        background(0);
        pg1.beginDraw();
            pg1.image(img,0,0);
        pg1.endDraw();

        pg2.beginDraw();
            pg2.image(img,0,0);
            decolorizeGraphics(pg2,0,0);
            drawHist(histGraphics, pg2);
            convoluteGraphics(pg2);
        pg2.endDraw();

        pg3.beginDraw();
            pg3.image(img,0,0);
            decolorizeGraphics(pg3,0,1);
        pg3.endDraw();




        image(pg1,0,0);
        image(pg2,img.width,0);
        image(pg3,2*img.width,0);
        image(histGraphics, 0, img.height);

    }

    public void mousePressed(){
        if (mouseX>=0 && mouseX<=histGraphics.width && mouseY>=img.height && mouseY<img.height+histGraphics.height){
            from = (int)map(mouseX, 0, histGraphics.width, 0, 255);
            to=from;//porque aja
        }
    }

    public void mouseReleased(){
        if (mouseY>=img.height && mouseY<img.height+histGraphics.height){
            int x = (mouseX<0)?0:(mouseX>histGraphics.width)?histGraphics.width:mouseX;
            to = (int)map(x, 0, histGraphics.width, 0, 255);
        }
    }

    public void mouseDragged(){
        if (mouseY>=img.height && mouseY<img.height+histGraphics.height){
            int x = (mouseX<0)?0:(mouseX>histGraphics.width)?histGraphics.width:mouseX;
            to = (int)map(x, 0, histGraphics.width, 0, 255);

        }
    }

    public void drawHist(PGraphics histogramPg, PGraphics source){
        int hist[] = new int[256];
        source.loadPixels();

        //based on https://processing.org/examples/histogram.html
        for (int i = 0 ; i<source.pixels.length;i++) {
            int b = (int) brightness(source.pixels[i]);
            hist[b]++;
        }
        int histMax = max(hist);
        histogramPg.beginDraw();
            for (int i = 0; i < histogramPg.width; i += 2) {
                // Map i (from 0..img.width) to a location in the histogram (0..255)
                int which = (int)map(i, 0, histogramPg.width, 0, 255);
                int y = (int)map(hist[which], 0, histMax, histogramPg.height, 0);

                if(which>=min(from,to) && which<=max(from,to))histogramPg.stroke(255,0,0);
                else histogramPg.stroke(255,255,255);
                histogramPg.line(i, histogramPg.height, i, y);
            }
        histogramPg.endDraw();

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

    public void decolorizeGraphics(PImage pg, int mode, int hide){
        pg.loadPixels();
        if (mode == 0){// rgb avg
            for (int i = 0 ; i < pg.pixels.length;i++){
                float avg = (red(pg.pixels[i]) + green(pg.pixels[i]) + blue(pg.pixels[i])) / 3.0f ;
                if(hide==1)
                    pg.pixels[i] = (avg>=min(from,to) && avg<=max(from,to))? color(0):color(255);
                else
                    pg.pixels[i] = color(avg, avg, avg);
            }
        }else{// luma
            for (int i = 0 ; i < pg.pixels.length;i++){
                float luma = 0.299f * red(pg.pixels[i]) + 0.587f * green(pg.pixels[i]) + 0.114f * blue(pg.pixels[i]);
                if (hide==1)
                    pg.pixels[i] = (luma>=min(from,to) && luma<=max(from,to))? color(0):color(255);
                else
                    pg.pixels[i] = color(luma, luma, luma);
            }
        }
        pg.updatePixels();
    }
}
