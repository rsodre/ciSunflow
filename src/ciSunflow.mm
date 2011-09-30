//
//  ciSunflow.mm
//
//  Created by Roger Sodre on 25/07/2011
//  Copyright 2011 Studio Avante. All rights reserved.
//

#include "ciSunflow.h"

using namespace ci;
using namespace ci::app;
using namespace std;

#define SUNFLOW_SHELL_FOLDER	"../../../../../lib/"

#define _sf						Sunflow::get()

//           4----5
//           | -y |
// 5----4----0----1----5
// | -z | -x | +z | +x |
// 7----6----2----3----7
//           | +y |
//           6----7
const Vec3f __cubeVertices[8] = {
	Vec3f( -0.5f, -0.5f, +0.5f ), Vec3f( +0.5f, -0.5f, +0.5f ), Vec3f( -0.5f, +0.5f, +0.5f ), Vec3f( +0.5f, +0.5f, +0.5f ),	// +Z front
	Vec3f( -0.5f, -0.5f, -0.5f ), Vec3f( +0.5f, -0.5f, -0.5f ), Vec3f( -0.5f, +0.5f, -0.5f ), Vec3f( +0.5f, +0.5f, -0.5f )	// +Z back
};
#define cv(i)	Vec3f(__cubeVertices[i].x,__cubeVertices[i].y,__cubeVertices[i].z)
const Vec3f __cubeVerticesStrip[6][4] = {		// [face][tri][vertex]
	{	cv(1),		cv(5),		cv(3),		cv(7) },	// +X right
	{	cv(2),		cv(3),		cv(6),		cv(7) },	// +Y bottom
	{	cv(0),		cv(1),		cv(2),		cv(3) },	// +Z front
	{	cv(4),		cv(0),		cv(6),		cv(2) },	// -X left
	{	cv(4),		cv(5),		cv(0),		cv(1) },	// -Y top
	{	cv(5),		cv(4),		cv(7),		cv(6) }		// -Z back
};
const Vec3f __cubeNormals[6] = {
	Vec3f(+1,0,0),	// +X right
	Vec3f(0,+1,0),	// +Y front
	Vec3f(0,0,+1),	// +Z up
	Vec3f(-1,0,0),	// -X right
	Vec3f(0,-1,0),	// -Y back
	Vec3f(0,0,-1)	// -Z down
};


namespace cinder { namespace sf {

	// Static instance of App, effectively a singleton
	Sunflow* Sunflow::sInstance;

	////////////////////////////////////////////////////////////////////////
	//
	// SUNFLOW CLASS
	//
	Sunflow::Sunflow()
	{
		sInstance = this;
		mCurrentShader = "default";
		mCurrentFilter = "gaussian";
		mCurrentAA = Vec2i(1,1);
		mCurrentSamples = 1;

	}
	Sunflow::~Sunflow()
	{
	}
	
	//
	// Export
	void Sunflow::save( std::string _path )
	{
		FILE *fp = fopen ( _path.c_str(), "w" );
		if (fp == NULL)
		{
			mStatus = "error saving to " + _path;
			return;
		}
		fputs(mStream.str().c_str(),fp);
		fclose (fp);
		mStatus = "saved to " + _path;
		printf("SAVED to [%s]\n",_path.c_str());
	}
	void Sunflow::saveAs()
	{
		std::vector<std::string> extensions;
		extensions.push_back("sc");
		std::string path = app::getSaveFilePath( app::getAppPath() + "/../", extensions );
		if ( path.length() )
			this->save( path );
	}
	void Sunflow::render()
	{
		std::string appName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] UTF8String];
		std::string fullPath = app::getAppPath() + "/../" + appName + ".sc";
		this->save( fullPath );
		// call renderer
		std::stringstream cmd;
		cmd << "cd " << SUNFLOW_SHELL_FOLDER << ";./sunflow " << fullPath << "&";
		system( cmd.str().c_str() );
	}
	void Sunflow::dump()
	{
		printf("%s\n",mStream.str().c_str());
	}
	
	//
	// Reset Sunflow Scene
	void Sunflow::reset()
	{
		mStream.str("");
		mCurrentColor = Color::white();
		mObjectCount = 0;
		
		// image tag
		this->open("image");
		this->add("resolution", getWindowSize() );
		this->add("aa", mCurrentAA );
		if ( mCurrentSamples > 1 )
			this->add("samples", mCurrentSamples);
		this->add("filter", mCurrentFilter);
		this->close();
		
		//
		// make default shaders
		this->open("shader");
		this->add("name", "default" );
		this->add("type", "shiny" );
		this->add("diff", Vec3f(0.2,0.2,0.2) );
		this->add("refl", 0.5f );
		this->close();
		//
		// Mirror shader
		this->open("shader");
		this->add("name", "mirror" );
		this->add("type", "mirror" );
		this->add("refl", Vec3f(0.7,0.7,0.7) );
		this->close();
		//
		// Glass shader
		this->open("shader");
		this->add("name", "glass" );
		this->add("type", "glass" );
		this->add("eta", 1.6f );
		this->add("color", Vec3f(1,1,1) );
		this->close();
	}
	
	
	void Sunflow::open( const std::string & _tag )
	{
		mStream << _tag << " {" << endl;
	}
	void Sunflow::openObject( const std::string & _type )
	{
		this->open("object");
		this->addShader();
		mStream << "\ttype " << _type << endl;
		mStream << "\tname " << _type << "_" << toString(mObjectCount++) << endl;
		//this->addColor();
	}
	void Sunflow::close()
	{
		mStream << "}" << endl;
		mStream << endl;
	}
	
	void Sunflow::setLight( const ci::gl::Light & light, const Color & aSpecular, float radius )
	{
		_sf->add("type",		"spherical");
		_sf->add("color",		aSpecular );
		_sf->add("radiance",	60 );
		_sf->add("center",		light.getPosition() );
		_sf->add("radius",		radius );
		_sf->add("samples",		8 );
		_sf->close();
	}
	
	
	//
	// TAGS
	//
	void Sunflow::add( const Vec2i & _v )
	{
		mStream << "\t" << _v.x << " " << _v.y << endl;
	}
	void Sunflow::add( const std::string & _tag, const std::string & _val )
	{
		mStream << "\t" << _tag << " " << _val << endl;
	}
	void Sunflow::add( const std::string & _tag, const float _f )
	{
		mStream << "\t" << _tag << " " << _f << endl;
	}
	void Sunflow::add( const std::string & _tag, const int _i )
	{
		mStream << "\t" << _tag << " " << _i << endl;
	}
	void Sunflow::add( const std::string & _tag, const Vec2i & _v )
	{
		mStream << "\t" << _tag << " " << _v.x << " " << _v.y << endl;
	}
	void Sunflow::add( const std::string & _tag, const Vec2f & _v )
	{
		mStream << "\t" << _tag << " " << _v.x << " " << _v.y << endl;
	}
	void Sunflow::add( const std::string & _tag, const Vec3i & _v )
	{
		mStream << "\t" << _tag << " " << _v.x << " " << _v.y << " " << _v.z << endl;
	}
	void Sunflow::add( const std::string & _tag, const Vec3f & _v )
	{
		mStream << "\t" << _tag << " " << _v.x << " " << _v.y << " " << _v.z << endl;
	}
	void Sunflow::add( const std::string & _tag, const Vec3f & _v, const Vec3f & _n, const Vec2i & _uv )
	{
		mStream << "\t" << _tag << " " << _v.x << " " << _v.y << " " << _v.z;
		mStream << "\t\t" << _n.x << " " << _n.y << " " << _n.z;
		mStream << "\t\t" << _uv.x << " " << _uv.y << endl;
	}
	void Sunflow::add( const std::string & _tag, const Color & _c )
	{
		this->add( _tag, ColorA( _c ) );
	}
	void Sunflow::add( const std::string & _tag, const ColorA & _c )
	{
		mStream << "\t" << _tag << " { \"sRGB nonlinear\" " << _c.r << " " << _c.g << " " << _c.b << " }" << endl;
	}
	// State values
	void Sunflow::addShader()
	{
		this->add( "shader", mCurrentShader );
	}
	void Sunflow::addColor()
	{
		this->add( "color", mCurrentColor );
	}
	
	////////////////////////////////////////////////////////////////////////
	//
	// OPENGL WRAPPERS
	//
	namespace gl {
		
		void setMatrices( const Camera &cam )
		{
			ci::gl::setMatrices( cam );
			// Make sunflow data
			_sf->open("camera");
			_sf->add("type",		"pinhole");
			_sf->add("eye",			cam.getEyePoint() );
			_sf->add("target",		(cam.getViewDirection() * cam.getFarClip()) + cam.getEyePoint() );
			_sf->add("up",			cam.getWorldUp() );
			_sf->add("fov",			cam.getFov() );
			_sf->add("aspect",		cam.getAspectRatio() );
			_sf->close();
			// defaut light
			_sf->open("light");
			_sf->add("type",		"sunsky");
			_sf->add("up",			Vec3f(0, 1, 0) );
			_sf->add("east",		Vec3f(0, 0, 1) );
			_sf->add("sundir",		cam.getViewDirection() );
			_sf->add("turbidity",	2 );
			_sf->add("samples",		32 );
			_sf->close();
		}
		
		void clear( const ColorA &color, bool clearDepthBuffer )
		{
			ci::gl::clear( color, clearDepthBuffer );
			// Make sunflow data
			/*
			_sf->open("background");
			_sf->add("color", color);
			_sf->close();
			*/
		}
		
		void color( const Color &c )
		{
			ci::gl::color(c);
			_sf->setColor( c );
		}
		void color( const ColorA &c )
		{
			ci::gl::color(c);
			_sf->setColor( c );
		}
		
		void drawSphere( const Vec3f &center, float radius, int segments )
		{
			ci::gl::drawSphere( center, radius, segments );
			// Make sunflow data
			_sf->openObject("sphere");
			_sf->add("c",	center);
			_sf->add("r",	radius);
			_sf->close();
		}

		void drawCube( const Vec3f & center, const Vec3f & size )
		{
			ci::gl::drawCube( center, size );
			// Make sunflow data
			_sf->openObject("mesh");
			_sf->add( Vec2i( 6*4, 6*2 ) );
			for (int f = 0 ; f < 6 ; f++)
				for (int v = 0 ; v < 4 ; v++)
					_sf->add( "v", center + (__cubeVerticesStrip[f][v] * size), __cubeNormals[f], Vec2i(0,0) );
			for (int f = 0 ; f < 6 ; f++)
			{
				int ix = f * 4;
				_sf->add( "t", Vec3i( ix+0, ix+1, ix+2) );
				_sf->add( "t", Vec3i( ix+1, ix+2, ix+3) );
			}
			_sf->close();
		}
	}
	
	
	
} } // cinder::sf::
