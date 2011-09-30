//
//	MyApp.h
//
//  Created by Roger Sodre on 14/05/10.
//	Copyright 2010 Studio Avante. All rights reserved.
//
#pragma once

#include "cinder/Cinder.h"
#include "cinder/app/AppBasic.h"
#include "cinder/Utilities.h"
#include "cinder/Vector.h"
#include "cinder/Rand.h"
#include "cinder/Camera.h"
#include "cinder/Font.h"
#include "cinder/Text.h"
#include "cinder/gl/gl.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/gl/Light.h"
#include "cinder/gl/Material.h"

#include "ciSunflow.h"

using namespace ci;
using namespace ci::app;

class MyApp : public AppBasic {
 public:
	void prepareSettings( Settings *settings );
	void setup();
	void shutdown();

	void resize( ResizeEvent event );
	void keyDown( KeyEvent event );
	void update();
	
	void draw();
	void renderScene();

	gl::GlslProg		mShader;
	gl::Light			*mLight;
	gl::Material		mMaterial;
	CameraPersp			mCam;
	Vec3f				mEye;
	Vec3f				mUp;
	Vec3f				mCenter;
	Vec2f				mGridSize;
	Font				mFont;

	sf::Sunflow			sunflow;
};




