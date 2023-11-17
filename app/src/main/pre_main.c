#include <stdlib.h>


#ifdef __cplusplus
extern "C"
{
#endif

int main(int argc, char* argv[]);

#ifdef __cplusplus
}
#endif

void rtems_stack_checker_report_usage(void);

void* POSIX_Init(void* p)
{
  int argc = 1;
  char *argv[] = { "dummy" };
  int exit_status = main(argc, argv);
  rtems_stack_checker_report_usage();
  exit(exit_status);
  return NULL;
}

#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER

#define CONFIGURE_MAXIMUM_FILE_DESCRIPTORS 4
#define CONFIGURE_MAXIMUM_DRIVERS 4

#define CONFIGURE_MAXIMUM_USER_EXTENSIONS 4
#define CONFIGURE_MAXIMUM_POSIX_KEYS 8
#define CONFIGURE_MAXIMUM_POSIX_QUEUED_SIGNALS 8

#define CONFIGURE_UNLIMITED_OBJECTS
#define CONFIGURE_UNIFIED_WORK_AREAS

#define CONFIGURE_POSIX_INIT_THREAD_STACK_SIZE (8 *1024)
#define CONFIGURE_MINIMUM_TASK_STACK_SIZE (4 * 1024)

#define CONFIGURE_STACK_CHECKER_ENABLED
#define CONFIGURE_POSIX_INIT_THREAD_TABLE
#define CONFIGURE_INIT

#include <rtems.h>
#include <rtems/confdefs.h>
