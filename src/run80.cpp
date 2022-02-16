/*****************************************************************************
 ________          ___ ________  ________          ________  ________  ___  ___     
|\_____  \        /  /|\   __  \|\   __  \        |\   ____\|\   __  \|\  \|\  \    
 \|___/  /|      /  //\ \  \|\  \ \  \|\  \       \ \  \___|\ \  \|\  \ \  \\\  \   
     /  / /     /  //  \ \   __  \ \  \\\  \       \ \  \    \ \   ____\ \  \\\  \  
    /  /_/__   /  //    \ \  \|\  \ \  \\\  \       \ \  \____\ \  \___|\ \  \\\  \ 
   |\________\/_ //      \ \_______\ \_______\       \ \_______\ \__\    \ \_______\
    \|_______|__|/        \|_______|\|_______|        \|_______|\|__|     \|_______|
                                                                                    
MIT License

Copyright (c) 2022 Mike Sharkey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************************/

#include <run80.h>
#include <stdio.h>

run80::run80()
: m_mem(NULL)
, m_io(NULL)
, m_load(NULL)
, m_vm(NULL)
{
}

run80::~run80()
{
}

int run80::run(int argc,char** argv)
{
    if ( argc == 2 )
    {
        m_mem = new run80mem();
        if ( m_mem )
        {
            m_load = new load80(m_mem);
            if ( m_load )
            {
                if ( m_load->load(argv[1]) )
                {
                    m_io = new run80io();
                    if ( m_io )
                    {
                        m_vm = new sim80vm_z80a(m_mem,m_io);
                        if ( m_vm )
                        {
                            m_vm->step(m_load->entry_point());
                            for(;;)
                            {
                                m_vm->step();
                            }
                            delete m_vm;
                        }
                        else
                        {
                            fprintf( stderr, "failed to instantiate VM\n" );
                        }
                        delete m_io;
                    }
                    else 
                    {
                        fprintf( stderr, "failed to instantiate I/O\n" );
                    }
                }
                else 
                {
                    fprintf( stderr, "failed to load %s\n", argv[1]);
                }
                delete m_load;
            }
            else
            {
                fprintf( stderr, "failed to instantiate LOADER\n");
            }
            delete m_mem;
        }
        else
        {
            fprintf( stderr, "failed to instantiate MEM\n");
        }
    }
    else
    {
        fprintf( stderr, "usage: %s xxxxxx.s19\n", argv[0]);
    }
    return 1;
}

