//
//  MyApp.cpp
//
//  Created by Roger Sodre on 14/05/10.
//  Copyright 2010 Studio Avante. All rights reserved.
//
#include "MyApp.h"

Color light_ambient			= Color( 0.5, 0.5, 0.5 );
Color light_diffuse			= Color( 0.9, 0.9, 0.9 );
Color light_specular		= Color( 1.0, 1.0, 1.0 );
//Color no_mat				= Color( 0.0, 0.0, 0.0 );
Color mat_ambient			= Color( 0.25, 0.25, 0.25 );
Color mat_diffuse			= Color( 0.75, 0.75, 0.75 );
Color mat_specular			= Color( 1.0, 1.0, 1.0 );
//Color mat_emission			= Color( 1.0, 0.5, 0.0 );
GLfloat mat_shininess		= 128.0;

//
// MyApp
void MyApp::prepareSettings( Settings *settings )
{
	settings->setWindowSize( 640, 480 );
	settings->setFrameRate( 60.0f );
}

void MyApp::setup()
{
	Rand::randomize();

	mGridSize = Vec2f( 6.0, 4.0 );
	mShader = gl::GlslProg( loadResource( "shPhongPoint.vert" ), loadResource( "shPhongPoint.frag" ) );
	mFont = Font( "Courier", 12 );

	// setup Camera
	float aspect	= getWindowWidth() / (float)getWindowHeight();
	float dist		= getWindowWidth();
	float near		= 10.0f;
	float far		= (dist * 2.0) + 10.0;
	float fovV		= atanf((getWindowHeight()*0.5)/dist) * 2.0f;
	//float fovH	= atanf((w/2.0f)/dist) * 2.0f;
	float fovGl		= toDegrees(fovV);
	mCam = CameraPersp( getWindowWidth(), getWindowHeight(), fovGl );
	mCam.setPerspective( fovGl, aspect, near, far );
	mEye			= Vec3f( 0.0f, 0.0f, dist );
	mUp				= Vec3f::yAxis();
	mCenter			= Vec3f::zero();
	
	// setup Lights
	mLight = new gl::Light( gl::Light::POINT, 0 );
	mLight->setAmbient( light_ambient );
	mLight->setDiffuse( light_diffuse );
	mLight->setSpecular( light_specular );
	mLight->lookAt( mEye * 0.2, mCenter );
	mLight->update( mCam );
	// setup Material
	mMaterial.setAmbient( mat_ambient );
	mMaterial.setDiffuse( mat_diffuse );
	mMaterial.setSpecular( mat_specular );
	mMaterial.setShininess( mat_shininess );
	mMaterial.apply();
	
}

void MyApp::shutdown()
{
	delete mLight;
}


//////////////////////////////////////////////
//
// UPDATE
//
void MyApp::keyDown( KeyEvent event )
{
	switch( event.getChar() )
	{
		case 'r':
		case 'R':
			sunflow.render();
			break;
		case 's':
		case 'S':
			sunflow.saveAs();
			break;
		case 'd':
		case 'D':
			sunflow.dump();
			break;
	}
}

void MyApp::resize( ResizeEvent event )
{
}


void MyApp::update()
{
	Vec3f eye = mEye;
	eye.x += getWindowWidth() * 0.5 * ((getMousePos().x/(float)getWindowWidth())-0.5);
	//eye.y += getWindowHeight() * 0.5 * -((getMousePos().y/(float)getWindowHeight())-0.5);
	mCam.lookAt( eye, mCenter, mUp );

	sunflow.reset();
}



//////////////////////////////////////////////
//
// DRAW
//
void MyApp::draw()
{
	sf::gl::setMatrices( mCam );
	gl::setViewport( getWindowBounds() );
	mShader.bind();
	this->renderScene();
	mShader.unbind();
	
	glDisable( GL_LIGHTING );
	gl::setMatricesWindow( getWindowSize() );
	gl::disableDepthRead();
	gl::disableDepthWrite();
	gl::enableAlphaBlending();
	gl::drawString( "Press: [R]ender, [S]ave, [D]ump to console", Vec2f( 10, 10), Color::white(), mFont );
	gl::drawString( sunflow.getStatus(), Vec2f( 10, 25), Color::white(), mFont );
	gl::disableAlphaBlending();
}

void MyApp::renderScene()
{
	glPushMatrix();
	//gl::translate( -(getWindowSize() * 0.5) );
	
	glEnable( GL_LIGHTING );

	gl::enableDepthRead();
	gl::enableDepthWrite();

	sf::gl::clear( Color( 0, 0, 0 ) );
	sf::gl::color( Color::white() );

	// ciSunflow has a default sunlight. This would create a light bulb
	sunflow.setLight( *mLight, light_specular, 20.0 );

	//sf::gl::drawSphere( Vec3f::zero(), getWindowHeight()*0.25 );

	Vec3f start = Vec3f( -(getWindowSize() * 0.5), 0 );
	Vec3f sz = Vec3f( getWindowWidth()/mGridSize.x, getWindowHeight()/mGridSize.y, getWindowWidth()/mGridSize.x );
	for (int x = 0 ; x < mGridSize.x ; x++ )
	{
		for (int y = 0 ; y < mGridSize.y ; y++ )
		{
			Vec3f p = start + sz * Vec3f( x+0.5, y+0.5, -0.5 );
			if ( ((x%2)&&!(y%2)) || (!(x%2)&&(y%2)) )
			{
				sunflow.setShader( "default" );
				p.z -= sz.z * 0.5;
				sf::gl::drawCube( p, sz*0.5 );
			}
			else
			{
				sunflow.setShader( "mirror" );
				p.z += sz.z * 0.5;
				sf::gl::drawSphere( p, sz.x*0.5 );
			}
		}
	}
	
	glPopMatrix();

}



CINDER_APP_BASIC( MyApp, RendererGl )
