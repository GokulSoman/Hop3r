#include "per_threads.h"

int make_periodic(int unsigned period, struct periodic_info *info)
{
	static int next_sig;
	int ret;
	unsigned int ns;
	unsigned int sec;
	struct sigevent sigev;
	timer_t timer_id;
	struct itimerspec itval;

	/* Initialise next_sig first time through. We can't use static
	   initialisation because SIGRTMIN is a function call, not a constant */
	if (next_sig == 0)
		next_sig = SIGRTMIN;
	/* Check that we have not run out of signals */
	if (next_sig > SIGRTMAX)
		return -1;
	info->sig = next_sig;
	next_sig++;
	/* Create the signal mask that will be used in wait_period */
	sigemptyset(&(info->alarm_sig));
	sigaddset(&(info->alarm_sig), info->sig);

	/* Create a timer that will generate the signal we have chosen */
	sigev.sigev_notify = SIGEV_SIGNAL;
	sigev.sigev_signo = info->sig;
	sigev.sigev_value.sival_ptr = (void *)&timer_id;
	ret = timer_create(CLOCK_MONOTONIC, &sigev, &timer_id);
	if (ret == -1)
		return ret;

	/* Make the timer periodic */
	sec = period / 1000000;
	ns = (period - (sec * 1000000)) * 1000;
	itval.it_interval.tv_sec = sec;
	itval.it_interval.tv_nsec = ns;
	itval.it_value.tv_sec = sec;
	itval.it_value.tv_nsec = ns;
	ret = timer_settime(timer_id, 0, &itval, NULL);
	return ret;
}

void wait_period(struct periodic_info *info)
{
	int sig;
	sigwait(&(info->alarm_sig), &sig);
}

int setup_periodic(void) {
  sigset_t alarm_sig;
	int i;

	pthread_mutex_init(&mutex1, NULL);

	printf("Periodic threads using POSIX timers\n");

	/* Block all real time signals so they can be used for the timers.
	   Note: this has to be done in main() before any threads are created
	   so they all inherit the same mask. Doing it later is subject to
	   race conditions */
	sigemptyset(&alarm_sig);
	for (i = SIGRTMIN; i <= SIGRTMAX; i++)
		sigaddset(&alarm_sig, i);
	sigprocmask(SIG_BLOCK, &alarm_sig, NULL);

  return 0;
}

void display_sched_attr(int policy, struct sched_param *param)
{
   printf("    policy=%s, priority=%d\n",
           (policy == SCHED_FIFO)  ? "SCHED_FIFO" :
           (policy == SCHED_RR)    ? "SCHED_RR" :
           (policy == SCHED_OTHER) ? "SCHED_OTHER" :
           "???",
           param->sched_priority);
}
