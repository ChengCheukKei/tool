 // ��׼��ͷ�ļ�  
#include <iostream>  
#include <string>  
#include <vector>   
// OpenCVͷ�ļ�  
#include <opencv2\core\core.hpp>  
#include <opencv2\highgui\highgui.hpp>  
#include <opencv2\imgproc\imgproc.hpp>   
// OpenNIͷ�ļ�  
#include <OpenNI.h>   
typedef unsigned char uint8_t;  
// namespace  
using namespace std;  
using namespace openni;  
using namespace cv;  

void CheckOpenNIError( Status result, string status )    
{     
    if( result != STATUS_OK )     
        cerr << status << " Error: " << OpenNI::getExtendedError() << endl;    
}   
  
int main( int argc, char **argv )  
{  
    Status result = STATUS_OK;        
  
    //opencv image  
    Mat cvBGRImg, cvRGBImg;   
    Mat cvDepthImg_vis, cvDepthImg_output;    
  
    //OpenNI2 image    
    VideoFrameRef oniDepthImg;    
    VideoFrameRef oniColorImg;  
  
    namedWindow("depth");    
    namedWindow("image");   
  
    // ��ʼ��OpenNI    
    result = OpenNI::initialize();  
    CheckOpenNIError( result, "initialize context" );   
      
    // open device      
    Device device;    
    result = device.open( openni::ANY_DEVICE );   
    CheckOpenNIError( result, "open device" );  
  
    // create depth stream     
    VideoStream oniDepthStream;    
    result = oniDepthStream.create( device, openni::SENSOR_DEPTH );  
    CheckOpenNIError( result, "create depth stream" );  
    
    // set depth video mode    
    VideoMode modeDepth;    
    modeDepth.setResolution( 640, 480 );    
    modeDepth.setFps( 30 );    
    modeDepth.setPixelFormat( PIXEL_FORMAT_DEPTH_1_MM );    
    oniDepthStream.setVideoMode(modeDepth);    
    // start depth stream    
    result = oniDepthStream.start();   
    CheckOpenNIError( result, "start depth stream" );  
     
    // create color stream    
    VideoStream oniColorStream;    
    result = oniColorStream.create( device, openni::SENSOR_COLOR );    
    CheckOpenNIError( result, "create color stream" );  
    // set color video mode    
    VideoMode modeColor;    
    modeColor.setResolution( 640, 480 );    
    modeColor.setFps( 30 );    
    modeColor.setPixelFormat( PIXEL_FORMAT_RGB888 );    
    oniColorStream.setVideoMode( modeColor);   
    // start color stream    
    result = oniColorStream.start();   
    CheckOpenNIError( result, "start color stream" );  
  
	//��ʼ�����
	int count = 1;
    while(true)  
    {  
		device.setImageRegistrationMode(IMAGE_REGISTRATION_DEPTH_TO_COLOR);
        // read frame    
        if( oniColorStream.readFrame( &oniColorImg ) == STATUS_OK )    
        {    
            // convert data into OpenCV type    
            Mat cvRGBImg_tmp( oniColorImg.getHeight(), oniColorImg.getWidth(), CV_8UC3, (void*)oniColorImg.getData() );
			cvRGBImg = cvRGBImg_tmp;
            cvtColor( cvRGBImg_tmp, cvBGRImg, CV_RGB2BGR );    
            //imshow( "image", cvBGRImg );//cv�Ĳ�ɫͼ��BGR��ʽ 
        }    
  
        if( oniDepthStream.readFrame( &oniDepthImg ) == STATUS_OK )    
        {    
            Mat cvRawImg16U( oniDepthImg.getHeight(), oniDepthImg.getWidth(), CV_16UC1, (void*)oniDepthImg.getData() );    
            /*cvRawImg16U.convertTo( cvDepthImg, CV_8U, 255.0/(oniDepthStream.getMaxPixelValue()));*/
			cvRawImg16U.convertTo( cvDepthImg_output, CV_16U );//CV_16U���պð�65536mm�ڵ����ֵ��ʾ�����������pngͼ
			cvRawImg16U.convertTo( cvDepthImg_vis, CV_8U, 255.0/(oniDepthStream.getMaxPixelValue()) );//CV_8U���ܽ���visualization
            imshow( "depth", cvDepthImg_vis );     //cvDepthImg��Mat��ʽ
        }    
        // quit  
        if( cv::waitKey( 1 ) == 'q' )        
            break;  
    
		//����ĳ�ѭ����ȡ���ͼ/��ɫͼ
        //get data    
		const int saveFPS = 1;
		if(count % saveFPS == 0){
			stringstream ss; ss.clear(); ss << count/saveFPS; 
			string rgbFile_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\background\\colormap\\color"+ss.str()+".png";
			string depthFile_output_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\background\\depthmap\\depth_output"+ss.str()+".png";
			string depthFile_vis_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\background\\depthmap\\depth_vis"+ss.str()+".png";

			/*string rgbFile_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\foreground\\colormap\\color"+ss.str()+".png";
			string depthFile_output_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\foreground\\depthmap\\depth_output"+ss.str()+".png";
			string depthFile_vis_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\foreground\\depthmap\\depth_vis"+ss.str()+".png";*/

			/*string rgbFile_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\testData\\color"+ss.str()+".png";
			string depthFile_output_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\testData\\depth_output"+ss.str()+".png";
			string depthFile_vis_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\tankData\\testData\\depth_vis"+ss.str()+".png";*/

			//string rgbFile_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\testRegistration\\afterReg\\color"+ss.str()+".png";
			//string depthFile_output_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\testRegistration\\afterReg\\depth_output"+ss.str()+".png";
			//string depthFile_vis_address = "E:\\Code\\vs2010\\oni2picture_ed2\\oni2picture_ed2\\testRegistration\\afterReg\\depth_vis"+ss.str()+".png";

			const char* c_rgb = rgbFile_address.c_str();
			const char* c_depth_output = depthFile_output_address.c_str();
			const char* c_depth_vis = depthFile_vis_address.c_str();
			/* cvSaveImage(c_rgb, &(IplImage(cvBGRImg))); */
			cvSaveImage(c_rgb, &(IplImage(cvBGRImg))); //���RGB
			cvSaveImage(c_depth_output, &(IplImage(cvDepthImg_output)));//ÿ�����ص�����ֵ��λΪmm
			//cvSaveImage(c_depth_vis, &(IplImage(cvDepthImg_vis)));//���ڿ��ӻ�
		}

        count++;
		if(count == 151) break;
		
    } 

}  



