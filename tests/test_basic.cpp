#include "add.h"

#include <gtest/gtest.h>

TEST(BasicAddition, BasicAddition) {
    EXPECT_EQ(add(20, 22), 42);
}
