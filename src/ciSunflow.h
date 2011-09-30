//
//	ciSunflow.h
//
//  Created by Roger Sodre on 25/07/2011
//  Copyright 2011 Studio Avante. All rights reserved.
//
#pragma once
#include "cinder/Cinder.h"
#include "cinder/app/AppBasic.h"
#include "cinder/Utilities.h"
#include "cinder/Vector.h"
#include "cinder/Camera.h"
#include "cinder/gl/gl.h"
#include "cinder/gl/Light.h"
#include "cinder/gl/Material.h"

namespace cinder { namespace sf {
	
	
	////////////////////////////////////////////////////////////////////////
	//
	// SUNFLOW CLASS
	//
	class Sunflow
	{
	public:
		Sunflow();
		~Sunflow();
		
		void save( std::string _path );
		void saveAs();
		void render();
		void dump();
		
		std::string getStatus()		{ return mStatus; }
		
		void reset();
		void open( const std::string & _tag );
		void openObject( const std::string & _type );
		void close();
		// state
		void setFilter( const std::string _filter )		{ mCurrentFilter = _filter; }
		void setAA ( const Vec2f & _aa )				{ mCurrentAA = _aa; }
		void setSamples( const int _samples )			{ mCurrentSamples = _samples; }

		void setShader( const std::string & _shader )	{ mCurrentShader = _shader; }
		void setColor( const Color &c )					{ mCurrentColor = c; }
		void setColor( const ColorA &c )				{ mCurrentColor = Color(c.r,c.b,c.b); }
		void setLight( const ci::gl::Light & light, const Color & aSpecular, float radius );
		// state tags
		void addColor();
		void addShader();
		// tags
		void add( const Vec2i & _v );
		void add( const std::string & _tag, const std::string & _val );
		void add( const std::string & _tag, const float _f );
		void add( const std::string & _tag, const int _i );
		void add( const std::string & _tag, const Vec2i & _v );
		void add( const std::string & _tag, const Vec2f & _v );
		void add( const std::string & _tag, const Vec3i & _v );
		void add( const std::string & _tag, const Vec3f & _v );
		void add( const std::string & _tag, const Vec3f & _v, const Vec3f & _n, const Vec2i & _uv );
		void add( const std::string & _tag, const Color & _c );
		void add( const std::string & _tag, const ColorA & _c );

		static Sunflow*	get() { return sInstance; }

		
	protected:

		static Sunflow*		sInstance;
		
		std::ostringstream	mStream;
		
		std::string			mCurrentFilter;
		Vec2f				mCurrentAA;
		int					mCurrentSamples;
		std::string			mCurrentShader;

		Color				mCurrentColor;
		int					mObjectCount;

		std::string			mStatus;

	};

	

	////////////////////////////////////////////////////////////////////////
	//
	// OPENGL WRAPPERS - substitute gl::xxx() funcitons
	//
	namespace gl {
		void setMatrices( const Camera &cam );
		void color( const Color &c );
		void color( const ColorA &c );
		void clear( const ColorA &color = ColorA::black(), bool clearDepthBuffer = true );
		void drawSphere( const Vec3f &center, float radius, int segments = 12 );
		void drawCube( const Vec3f &center, const Vec3f &size );
	}
	
	
} }  // cinder::sf::
