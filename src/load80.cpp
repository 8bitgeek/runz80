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

#include <load80.h>
#include <stdio.h>
#include <string.h>

static int meta_fn(srec_reader_t* srec_reader);
static int store_fn(srec_reader_t* srec_reader);
static int term_fn(srec_reader_t* srec_reader);
static int fault_fn(srec_reader_t* srec_reader);

/** ================= srec_reader 'C' callbacks ==================== */

static int meta_fn(srec_reader_t* srec_reader)
{
    /* handle meta records */
    if ( srec_reader->arg )
    {
        load80* load80p = (load80*)srec_reader->arg;
        return load80p->cb_meta_fn(srec_reader);
    }
    return -1;
}

static int store_fn(srec_reader_t* srec_reader)
{
    /* handle data records */
    if ( srec_reader->arg )
    {
        load80* load80p = (load80*)srec_reader->arg;
        return load80p->cb_store_fn(srec_reader);
    }    
    return -1;
}

static int term_fn(srec_reader_t* srec_reader)
{
    /* handle termination records */
    if ( srec_reader->arg )
    {
        load80* load80p = (load80*)srec_reader->arg;
        return load80p->cb_term_fn(srec_reader);
    }    
    return -1;
}

static int fault_fn(srec_reader_t* srec_reader)
{
    /* handle fault records */
    if ( srec_reader->arg )
    {
        load80* load80p = (load80*)srec_reader->arg;
        return load80p->cb_fault_fn(srec_reader);
    }    
    return -1;
}

/* ================================================================== */

load80::load80(run80mem* mem,const char* name)
: m_mem(mem)
, m_file(NULL)
, m_name(name)
, m_success(false)
, m_entry_point(0)
{

}

load80::~load80()
{

}

bool load80::load(const char* name)
{
    if ( name )
        m_name = name;

    if ( m_name )
    {
        m_file = fopen(m_name,"r");
        if ( m_file )
        {
            srec_reader_init(
                                &m_srec_state,
                                m_file,
                                meta_fn,
                                store_fn,
                                term_fn,
                                fault_fn,
                                m_line,
                                LOAD_Z80_MAX_LINE,
                                this
                            );
            m_success = true; // assume success
            srec_reader_read( &m_srec_state );
            fclose(m_file);
            m_file=NULL;
            return m_success;
        }
    }
    return false;

}

int load80::cb_meta_fn(srec_reader_t* srec_state)
{
    // srec_result_t* result = &srec_state->record;
    // printf( "MT: ", result->address );
    // for(uint32_t count=0; count < result->length; count++)
    // {
    //     uint8_t data = result->data[count];
    //     printf( "%02X ", data );
    // }
    // printf("\n");
    return 0;

}

int load80::cb_store_fn(srec_reader_t* srec_state)
{
    srec_result_t* result = &srec_state->record;
    for(uint32_t count=0; count < result->length; count++)
    {
        uint32_t load_address = result->address+count;
        uint8_t data = result->data[count];
        printf( "LD: %08x: %02X \n", load_address, data );
        m_mem->put((uint16_t)load_address&0xFFFF,data);
    }
    return 0;
}

int load80::cb_term_fn(srec_reader_t* srec_state)
{
    srec_result_t* result = &srec_state->record;
    printf( "TM: %08x\n", result->address );
    m_entry_point = result->address;
    return 0;
}

int load80::cb_fault_fn(srec_reader_t* srec_state)
{
    // srec_result_t* result = &srec_state->record;
    //printf( "TM: %08x\n", result->address );
    return 0;
}

