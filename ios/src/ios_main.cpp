#define SDL_MAIN_HANDLED
#include <SDL3/SDL_main.h>

extern "C" int SDL_main( int argc, char **argv );

int main( int argc, char **argv )
{
    return SDL_RunApp( argc, argv, SDL_main, nullptr );
}
