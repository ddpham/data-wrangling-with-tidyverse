#+++++++++++++++++++++++++++++++++
# Các ví dụ đơn giản với pipeR 
#+++++++++++++++++++++++++++++++++

## Trong bài viết này tôi sử dụng pipe operator của pipeR thay vì pipe operator trong gói `dplyr`

#+++++++++++++++++++++++++++++++++
# 2 Pipe operator
#+++++++++++++++++++++++++++++++++
## Ví dụ 1:
  x <- seq(2, 100, 2)
  
  # Tính độ lệch chuẩn
  sqrt(sum((x-mean(x))^2)/(length(x)-1))
  sd(x)
  
  # Sử dụng %>%:
  ((x - x %>% mean)^2 %>% sum / (x %>% length - 1)) %>% sqrt
  
  mean(x) 
  # Tương đương với:
  x %>% mean
  
  sqrt(sum(x)) * 100
  # Tương đương với:
  x %>% sum %>% sqrt * 100
  sqrt(x %>% sum) # trong ví dụ này, x %>% sum được hiểu là biến của hàm sqrt. 
  
  model1 <- mtcars %>% lm(mpg ~ cyl + disp + wt, data = .)
  model1 %>% summary

## Ví dụ 2:  
  mtcars %>%
    subset(hp > 100) %>%
    aggregate(. ~ cyl, data = ., FUN = . %>% mean %>% round(2)) %>%
    transform(kpl = mpg * 0.4251)
  # Tương đương với:
  new_func <- function(x){
    return(round(mean(x), 2))
  }
  mtcars %>%
    subset(hp > 100) %>%
    aggregate(. ~ cyl, data = ., FUN = new_func) %>%
    transform(kpl = mpg * 0.4251)

## Ví dụ 3:
  check_data <- function(x){
    if(is.numeric(x)) print("variable is numeric")
    if(is.logical(x)) print("variable is logical")
    if(is.factor(x)) print("variable is factor")
    if(is.character(x)) print("variable is charactor")
  }
  check_data(5)
  check_data("5")
  x <- seq(2, 10, 1)
  check_data(x)
  y <- c("I", "am", "Duc")
  check_data(y)
  y <- as.factor(y)
  check_data(y)
  
  #Cấu trúc nhanh với %>%: bạn có thể truyền yếu tố LHS qua hàm mới bạn đang định nghĩa, như sau:
  5 %>% 
  (function(x){
    if(is.numeric(x)) print("variable is numeric")
    if(is.logical(x)) print("variable is logical")
    if(is.factor(x)) print("variable is factor")
    if(is.character(x)) print("variable is charactor")
  })

  x %>%
    (function(x){
      if(is.numeric(x)) print("variable is numeric")
      if(is.logical(x)) print("variable is logical")
      if(is.factor(x)) print("variable is factor")
      if(is.character(x)) print("variable is charactor")
    })
