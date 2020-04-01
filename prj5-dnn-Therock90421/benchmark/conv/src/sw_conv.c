#include "printf.h"
#include "trap.h"
#include "mul.h"
#include "div.h"
#include "perf_cnt.h"

#define FRAC_BIT        10

#define RD_ADDR         135106448
#define RD_SIZE_D0      1
#define RD_SIZE_D1      1
#define RD_SIZE_D2      28
#define RD_SIZE_D3      28

#define WEIGHT_ADDR     134217728
#define WEIGHT_SIZE_D0  20
#define WEIGHT_SIZE_D1  1
#define WEIGHT_SIZE_D2  5
#define WEIGHT_SIZE_D3  5

#define WR_ADDR         135108240
#define WR_SIZE_D0      1
#define WR_SIZE_D1      20
#define WR_SIZE_D2      12
#define WR_SIZE_D3      12

#define KERN_ATTR_CONV_PAD          0
#define KERN_ATTR_CONV_STRIDE       1
#define KERN_ATTR_POOL_PAD          0
#define KERN_ATTR_POOL_KERN_SIZE    2
#define KERN_ATTR_POOL_STRIDE       2

struct size_vec4 {
    unsigned d0;
    unsigned d1;
    unsigned d2;
    unsigned d3;
};

struct mem_addr {
    unsigned rd_addr;
    unsigned weight_addr;
    unsigned wr_addr;
};

int mul(short a,short b) {
    int ans = mul_ll(a, b);
    return ans;
}

struct mem_addr addr = {RD_ADDR, WEIGHT_ADDR, WR_ADDR};
struct size_vec4 rd_size = {RD_SIZE_D0, RD_SIZE_D1, RD_SIZE_D2, RD_SIZE_D3};
struct size_vec4 wr_size = {WR_SIZE_D0, WR_SIZE_D1, WR_SIZE_D2, WR_SIZE_D3};
struct size_vec4 weight_size = {WEIGHT_SIZE_D0, WEIGHT_SIZE_D1, WEIGHT_SIZE_D2, WEIGHT_SIZE_D3};

struct size_vec4 conv_size;

void convolution() {
    short* in = (short*)addr.rd_addr;
    short* weight = (short*)addr.weight_addr;
    short* out = (short*)addr.wr_addr;

    unsigned output_offset = 0;                                    //d0:
    unsigned input_offset = 0;                                     //d1:
    unsigned weight_offset = 0;                                    //d2: hidth
                                                                   //d3: width
    unsigned input_fm_w = rd_size.d3;
    unsigned input_fm_h = rd_size.d2;

    unsigned pad = KERN_ATTR_CONV_PAD;
    unsigned pad_len = pad << 1;    //Extra length brought by two pads

    unsigned conv_out_w = rd_size.d3 - weight_size.d3 + pad_len;    //weight/rd_size.d3: the width  of weight/input
    unsigned conv_out_h = rd_size.d2 - weight_size.d2 + pad_len;    //weight/rd_size.d2: the height of weight/input

    unsigned stride = KERN_ATTR_CONV_STRIDE;                        //one move

    conv_out_w = div(conv_out_w, stride);
    conv_out_h = div(conv_out_h, stride);

    conv_out_w++;   //Size of Output Pictures
    conv_out_h++;   //using oh = (ih -kh + pad * 2) / stride + 1

    conv_size.d0 = wr_size.d0;  //Number of Input  Pictures
    conv_size.d1 = wr_size.d1;  //Number of Output Pictures
    conv_size.d2 = conv_out_h;  //Height of Output Pictures
    conv_size.d3 = conv_out_w;  //Width  of Output Pictures

    //TODO: Please add your own algorithm implementaion here

    int no, ni, y, x, padding_y, padding_x, ky, kx;
    int temp;
    int  temp_in, temp_w;

    for(no = 0; no < conv_size.d1; ++no)                                                                                                      //number of output pictures
    {
        input_offset = 0;   //reset input_offset
        
        for(ni = 0; ni < conv_size.d0; ++ni)                                                                                                  //number of input pictures
        {
            
            
            for(y = 0; y < conv_size.d2; ++y)   //point(x, y) of output picture
            {
                for(x = 0; x < conv_size.d3; ++x)                                                                                             //point (x,y) of output pictures
                {
                    padding_y = y * stride;                                                                  //padding_y is the y-coordinate in the input pictures(which include padding zone)
                    padding_x = x * stride;                                                                  //padding_x is the x-coordinate in the input pictures(which include padding zone) 
                    temp = 0;                                                                         //reset temp
                    if(ni == 0)                                                    //reset output picture(add bias, which is already of short type)
                        out[output_offset + y * conv_size.d3 + x] = weight[weight_offset];            //add bias to the output picture

                    for(ky = 0; ky < weight_size.d2; ++ky)  
                    {            
                        for(kx = 0; kx < weight_size.d3; ++kx)                                                                                 //point(kx,ky) of weight map
                        {
                            if(padding_x + kx >= pad && padding_x + kx < input_fm_w + pad && padding_y + ky >= pad && padding_y + ky < input_fm_h + pad)//not in the range of padding zone
                                temp_in = (short int)in[input_offset + (padding_y + ky - pad) * input_fm_w + (padding_x + kx - pad)];    //temp_in is the data of  point(padding_x+kx-pad, padding_y+ky-pad) of input pictures
                            else
                                temp_in = 0;    //point(padding_x+kx, padding_y+ky) is in padding zone

                            temp_w = (short int)(weight[weight_offset + ky * weight_size.d3 + kx + 1]);  //Filter[oc][0][0] is bias, thus plus 1 to skip it
                            temp += (int)(temp_in * temp_w);
                        }
                    }
                    out[output_offset + y * conv_size.d3 + x] += (short)(temp >> FRAC_BIT);  //MUL make the last 20 bits are decimal, only get first 10 of them,shift left 10 bits
                    
                    //calculate one point
                }        
                                                                            //complete one row
             }                                                  //complete one input picture                                                                                                              
            input_offset += input_fm_h * input_fm_w;                                                                                            //offset to the next input && weight
            weight_offset += weight_size.d2 * weight_size.d3 + 1;                                                                               //the size of the third field of Filter is 1+K*K 
                      
        }                                                                                                                                       //handle ont output picture
        output_offset += conv_size.d2 * conv_size.d3;                                                                                           //offset to next output picture
    }


}

void pooling() {
    short* out = (short*)addr.wr_addr;

    unsigned output_offset = 0;
    unsigned input_offset = 0;

    unsigned input_fm_w = conv_size.d3;
    unsigned input_fm_h = conv_size.d2;

    unsigned pad = KERN_ATTR_POOL_PAD;
    unsigned pad_len = pad << 1;

    unsigned pad_w_test = conv_size.d3 - KERN_ATTR_POOL_KERN_SIZE;
    unsigned pad_h_test = conv_size.d2 - KERN_ATTR_POOL_KERN_SIZE;

    unsigned pool_out_w = pad_w_test + pad_len;
    unsigned pool_out_h = pad_h_test + pad_len;

    unsigned stride = KERN_ATTR_POOL_STRIDE;

    unsigned pad_w_test_remain = pad_w_test - mul(div(pad_w_test, stride), stride);
    unsigned pad_h_test_remain = pad_h_test - mul(div(pad_h_test, stride), stride);

    pool_out_w = div(pool_out_w, stride);
    pool_out_h = div(pool_out_h, stride);
    pool_out_w++;
    pool_out_h++;

    if ( (!pad) && (pad_w_test_remain || pad_h_test_remain) )
    {
        pool_out_w++;
        pool_out_h++;
    }

    //TODO: Please add your own algorithm implementaion here
    int no, y, x, oy, ox, i, j;
    int maxium; //oy, ox: work on output from convolution
    int temp;

    for(no = 0; no < conv_size.d1; ++no)                                          //number of output pictures
    {
        
        
        for(y = 0; y < pool_out_h; ++y)                                           //point(x, y) of pooling output
        {
            for(x = 0; x < pool_out_w; ++x)
            {
                oy = y * stride;                                                  //pooling stride
                ox = x * stride;
                maxium = -2147483648;   //INT_MIN

                for(j = 0; j < stride; ++j)                                       //point(ox+i,oy+j) of pooling area
                {
                    for(i = 0; i < stride; ++i)
                    {
                        if(ox + i >= pad && ox + i < input_fm_w + pad && oy + j >= pad && oy + j < input_fm_h + pad)  //if point(ox+i,oy+j) is not in the padding 
                            temp = (short)out[input_offset + (oy + j - pad) * input_fm_w + (ox + i - pad)];
                        else
                            temp = 0;                                                                                 //point(ix+kx, iy+ky) is in padding zone

                        if(temp > maxium)
                            maxium = temp;
                    }
                }
                out[output_offset + y * pool_out_w + x] = maxium;  
                
            }
            
        }
        input_offset += input_fm_h * input_fm_w;  //Change into another input, which is the output of convolution
        
        output_offset += pool_out_h * pool_out_w;  //Change into another output
    }


}

int main()
{
    Result res;

    bench_prepare(&res);
    printf("starting convolution\n");
    convolution();
    printf("starting pooling\n");
    pooling();
    bench_done(&res);

    printf("Cycles of sw: %u\n", res.msec);
    printf("Memory visit times is: %u\n",res.mem_cycle);

    return 0;
}

