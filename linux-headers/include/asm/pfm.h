#ifndef __PFM_H_
#define __PFM_H_

struct pcounter {
	unsigned long long pfm0; /* value of $PFMC0 */
	unsigned long long pfm1; /* value of $PFMC1 */
	unsigned long long pfm2; /* value of $PFMC2 */
};


#endif
