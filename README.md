
Xử lý và tổng hợp dữ liệu với dplyr
Đức Phạm
February 21, 2017
1 Giới thiệu

Gói dplyr là gói được sử dụng phổ biến nhất trên R với những tính năng chuyên cho việc xử lý, tổng hợp dữ liệu trước khi xây dựng model phân tích dữ liệu. Bài giảng ngày hôm nay được xây dựng để hỗ trợ người dùng R có được cái nhìn tổng thể về khả năng tổng hợp và xử lý dữ liệu của R thông quan gói dplyr. Bài giảng cũng sẽ lồng ghép các hàm cơ bản trên R để người dùng có được cái nhìn khách quan hơn về các hàm trong gói dplyr. Trước khi bắt đầu nội dung bài giảng, chúng ta có thể download và gọi gói dplyr.

#install.packages("dplyr")
library(dplyr)

## 
## Attaching package: 'dplyr'

## The following objects are masked from 'package:stats':
## 
##     filter, lag

## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union

library(magrittr)

2 Giới thiệu về pipe operator

Pipe operator (%>%) là khái niệm về việc viết code theo cách đơn giản và dễ theo dõi giúp cho người đọc và người viết code trên R có thể theo dõi được code một cách dễ dàng nhất. Trên R, thông thường người dùng sẽ viết code dưới dạng trong ngoặc (nested), và cấu trúc câu lệnh sẽ phức tạp khi có nhiều thao tác tính toán, biến đổi (hàm) được xử dụng để trả về kết quả cuối cùng. Khái niệm pipe operator được khởi xướng từ gói magrittr với nhiều tính năng hữu dụng, hỗ trợ người viết code có thể viết code trên R được hiệu quả và dễ theo dõi hoặc sửa trong quá trình chạy và update code. Gói dplyr có ứng dụng một số tính năng cơ bản của pipe operator, cụ thể là cấu trúc %>% với một số tính năng cơ bản của pipe operator từ gói magrittr. Pipe operator được giới thiệu trong bài giảng này sẽ chỉ dừng lại ở phạm vi ứng dụng trong gói dplyr, các tính năng khác của pipe operator, bạn đọc có thể tìm hiểu trong tài liệu của gói magrittr .

Ví dụ đơn giản của %>%:

x <- seq(2, 100, 2)
# Tính độ lệch chuẩn
sqrt(sum((x-mean(x))^2)/(length(x)-1))

## [1] 29.15476

sd(x)

## [1] 29.15476

Câu lệnh ở trên rất phức tạp, cần nhiều đóng, mở ngoặc để gộp các hàm lại với nhau. Với pipe operator, câu lệnh của chúng ta sẽ đơn giản hơn như sau:

((x - x %>% mean)^2 %>% sum / (x %>% length - 1)) %>% sqrt

## [1] 29.15476

Trong ví dụ trên, chúng ta cần phải dùng tổng cộng 6 cặp (), tuy nhiên, khi dùng pipe operator, số lượng cặp () giảm đi còn 3 (1/2!). Logic của pipe operator khá khác biệt so với logic của (). Đối với (), chúng ta sẽ đọc thông tin từ trong cặp () bên trong ra cặp () bên ngoài, trong khi đó, logic của pipe operator là code được đọc từ trái sang phải. Pipe operator vẫn tuân theo các quy luật tính toán cơ bản trong toán học như các ccông thức trong ngoặc () sẽ được xử lý trước và quy tắc xử lý các thuật toán, công thức toán học sẽ trái sang phải…

Diễn giải cho ví dụ trên: x trừ trung bình của x; tất cả sau đó bình phương; sau đó được tính tổng lại; rồi chia cho 1 số, số này là tổng số của các giá trị nằm trong x trừ đi 1; kết quả của phép chia trên được căn bậc 2 để lấy kết quả cuối cùng

Một số đặc tính cơ bản của %>%:

    Theo mặc định, Phía tay trái (LHS) sẽ được chuyển tiếp thành yếu tố đầu tiên của hàm được sử dụng phía tay phải (RHS), ví dụ:

mean(x) 

## [1] 51

# Tương đương với:
x %>% mean

## [1] 51

sqrt(sum(x)) * 100

## [1] 5049.752

# Tương đương với:
x %>% sum %>% sqrt * 100

## [1] 5049.752

    %>% có thể được sử dụng trong dạng (), tuy nhiên, được xuất hiện trong một cú pháp là biến của một hàm, ví dụ:

sqrt(x %>% sum) # trong ví dụ này, x %>% sum được hiểu là biến của hàm sqrt. 

## [1] 50.49752

    Khi LHS không còn là yếu tố đầu tiên của một hàm RHS, thì dấu “.” được sử dụng để định vị cho LHS, ví dụ:

model1 <- mtcars %>% lm(mpg ~ cyl + disp + wt, data = .)
model1 %>% summary

## 
## Call:
## lm(formula = mpg ~ cyl + disp + wt, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -4.4035 -1.4028 -0.4955  1.3387  6.0722 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 41.107678   2.842426  14.462 1.62e-14 ***
## cyl         -1.784944   0.607110  -2.940  0.00651 ** 
## disp         0.007473   0.011845   0.631  0.53322    
## wt          -3.635677   1.040138  -3.495  0.00160 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 2.595 on 28 degrees of freedom
## Multiple R-squared:  0.8326, Adjusted R-squared:  0.8147 
## F-statistic: 46.42 on 3 and 28 DF,  p-value: 5.399e-11

Trong tình huống trên, tham số về dữ liệu trong hàm lm không phải là ở đầu, mà sau phần công thức, nên chúng ta sẽ dùng dấu “.” như là đại diện của thực thể mtcars ở bên ngoài (LHS) của hàm lm.

    Khi hàm RHS chỉ yêu cầu có một yếu tố, thì () có thể được lược bỏ để code được tối giản (ví dụ như ở ví dụ mục 3)

    Dấu “.” trong pipe operator đôi khi cũng được đặt LHS của pipe operator có thể được sử dụng như là một hàm và hàm này là kết quả của chuỗi hàm RHS, ví dụ:

mtcars %>%
  subset(hp > 100) %>%
  aggregate(. ~ cyl, data = ., FUN = . %>% mean %>% round(2)) %>%
  transform(kpl = mpg * 0.4251)

##   cyl   mpg   disp     hp drat   wt  qsec   vs   am gear carb       kpl
## 1   4 25.90 108.05 111.00 3.94 2.15 17.75 1.00 1.00 4.50 2.00 11.010090
## 2   6 19.74 183.31 122.29 3.59 3.12 17.98 0.57 0.43 3.86 3.43  8.391474
## 3   8 15.10 353.10 209.21 3.23 4.00 16.77 0.00 0.14 3.29 3.50  6.419010

# Tương đương với:
new_func <- function(x){
  return(round(mean(x), 2))
}

mtcars %>%
  subset(hp > 100) %>%
  aggregate(. ~ cyl, data = ., FUN = new_func) %>%
  transform(kpl = mpg * 0.4251)

##   cyl   mpg   disp     hp drat   wt  qsec   vs   am gear carb       kpl
## 1   4 25.90 108.05 111.00 3.94 2.15 17.75 1.00 1.00 4.50 2.00 11.010090
## 2   6 19.74 183.31 122.29 3.59 3.12 17.98 0.57 0.43 3.86 3.43  8.391474
## 3   8 15.10 353.10 209.21 3.23 4.00 16.77 0.00 0.14 3.29 3.50  6.419010

Một khái niệm quan trọng của của %>% có thể được sử dụng thường xuyên trong dplyr là lambda. Khái niệm này được sử dụng khi chúng ta truyền yếu tố phía tay trái (LHS) vào một hàm mới chưa được định nghĩa sẵn mà có thể tối giản cấu chúc của hàm này. Ví dụ:

Chúng ta muốn tạo ra một hàm để check loại dữ liệu của một biến, chúng ta sẽ làm theo 2 bước tuần tự sau: 1) tao hạm, 2) áp dụng hàm cho biến

Bước 1: tạo hàm

check_data <- function(x){
  if(is.numeric(x)) print("variable is numeric")
  if(is.logical(x)) print("variable is logical")
  if(is.factor(x)) print("variable is factor")
  if(is.character(x)) print("variable is charactor")
}

Bước 2: Áp dụng hàm cho biến

check_data(5)

## [1] "variable is numeric"

check_data("5")

## [1] "variable is charactor"

x <- seq(2, 10, 1)
check_data(x)

## [1] "variable is numeric"

y <- c("I", "am", "Duc")
check_data(y)

## [1] "variable is charactor"

y <- as.factor(y)
check_data(y)

## [1] "variable is factor"

Cấu trúc nhanh với %>%: bạn có thể truyền yếu tố LHS qua hàm mới bạn đang định nghĩa, như sau:

5 %>% 
  (function(x){
    if(is.numeric(x)) print("variable is numeric")
    if(is.logical(x)) print("variable is logical")
    if(is.factor(x)) print("variable is factor")
    if(is.character(x)) print("variable is charactor")
  })

## [1] "variable is numeric"

x %>%
 (function(x){
    if(is.numeric(x)) print("variable is numeric")
    if(is.logical(x)) print("variable is logical")
    if(is.factor(x)) print("variable is factor")
    if(is.character(x)) print("variable is charactor")
  })

## [1] "variable is numeric"

Tất nhiên, lamda trong gói dplyr chỉ thực sự hữu dụng khi chúng ta dùng hàm này một lần và không muốn mất công tạo một hàm mới, nếu hàm được sử dụng nhiều lần thì cách tốt nhất là định nghĩa hàm, sau đó dùng %>% để truyền biến vào hàm.
3 Các hàm cơ bản trong dplyr
3.1 Lấy dữ liệu mẫu từ bảng dữ liệu

Khi tiếp cận với một bảng dữ liệu, phần lớn người phân tích và xử lý dữ liệu thường làm thao tác đầu tiên là quan sát các giá trị mẫu của dữ liệu. Trong R Base, chắc hẳn các bạn đều dùng hàm head() và tail() để nhặt ra một số dòng đầu tiên và cuối cùng của dữ liệu.

mtcars %>% head(5) # lấy 5 dòng đầu của dữ liệu

##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2

mtcars %>% tail(5) # lấy 5 dòng cuối của dữ liệu

##                 mpg cyl  disp  hp drat    wt qsec vs am gear carb
## Lotus Europa   30.4   4  95.1 113 3.77 1.513 16.9  1  1    5    2
## Ford Pantera L 15.8   8 351.0 264 4.22 3.170 14.5  0  1    5    4
## Ferrari Dino   19.7   6 145.0 175 3.62 2.770 15.5  0  1    5    6
## Maserati Bora  15.0   8 301.0 335 3.54 3.570 14.6  0  1    5    8
## Volvo 142E     21.4   4 121.0 109 4.11 2.780 18.6  1  1    4    2

Tuy nhiên các hàm head() và tail() đều đưa ra các gía trị của các dòng dữ liệu đầu tiên và cuối cùng của bảng dữ liệu. Khác với các hàm này một chút, trong gói dplyr, bạn có thể dùng hàm sample_n() hoặc hàm sample_frac() để lấy dữ liệu của các dòng ngẫu nhiên trong bảng dữ liệu. Với hàm sample_n() cho ta số lượng dòng theo yêu cầu, còn sample_frac() cho ta số lượng dòng bằng tỷ trọng của tổng số lượng dòng của toàn bộ bảng dữ liệu. Hàm sample_n() giống với cấu trúc lấy dữ liệu mẫu ngẫu nhiên trong SQL.

mtcars %>% sample_n(10) # lấy 10 dòng dữ liệu ngẫu nhiên trong bảng mtcars - tương đương với cấu trúc: "SELECT TOP 10 * FROM MTCARS" trong SQL.

##                      mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## Maserati Bora       15.0   8 301.0 335 3.54 3.570 14.60  0  1    5    8
## Dodge Challenger    15.5   8 318.0 150 2.76 3.520 16.87  0  0    3    2
## Merc 230            22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
## Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4
## Merc 280C           17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## Ferrari Dino        19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
## Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## Toyota Corona       21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1

iris %>% sample_frac(.1) # lấy 10 % tổng số dòng có trong bảng iris

##     Sepal.Length Sepal.Width Petal.Length Petal.Width    Species
## 109          6.7         2.5          5.8         1.8  virginica
## 69           6.2         2.2          4.5         1.5 versicolor
## 60           5.2         2.7          3.9         1.4 versicolor
## 3            4.7         3.2          1.3         0.2     setosa
## 120          6.0         2.2          5.0         1.5  virginica
## 99           5.1         2.5          3.0         1.1 versicolor
## 145          6.7         3.3          5.7         2.5  virginica
## 8            5.0         3.4          1.5         0.2     setosa
## 42           4.5         2.3          1.3         0.3     setosa
## 84           6.0         2.7          5.1         1.6 versicolor
## 94           5.0         2.3          3.3         1.0 versicolor
## 41           5.0         3.5          1.3         0.3     setosa
## 143          5.8         2.7          5.1         1.9  virginica
## 71           5.9         3.2          4.8         1.8 versicolor
## 137          6.3         3.4          5.6         2.4  virginica

Ngoài việc nhìn nhanh các thông tin trên bảng dữ liệu mà bạn muốn phân tích, hai hàm trên cũng hỗ trợ bạn trong việc lấy dữ liệu mẫu của một bảng dữ liệu để phân tích hoặc xây dựng mô hình.
3.2 Lọc dữ liệu theo điều kiện

Thường xuyên trong quá trình xử lý và phân tích dữ liệu, người dùng sẽ phải lọc dữ liệu theo điều kiện nào đó, ví dụ lấy danh sách khách hàng nam có độ tuổi từ 35 trở lên, lấy các hợp đồng có giá trị từ 10 triệu trở lên hay đại loại vậy. Trong gói dplyr, hàm filter() và hàm slice() được sử dụng để làm công việc này.

filter(mtcars, mpg >= 21, cyl == 6)

##    mpg cyl disp  hp drat    wt  qsec vs am gear carb
## 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## 3 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1

Hàm filter() rất tương đồng với hàm subset() trong base R (đã được xây dựng sẵn trong môi trường gốc của R mà không cần gọi bất kỳ gói nào khi sử dụng). Với filter(), tên của dòng tự động bị loại bỏ, trong khi đó subset() vẫn lưu lại tên dòng của dữ liệu.

subset(mtcars, mpg >= 21 & cyl == 6)

##                 mpg cyl disp  hp drat    wt  qsec vs am gear carb
## Mazda RX4      21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag  21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1

Tương đương với:

mtcars %>%
  subset(mpg >= 21) %>%
  subset(cyl == 6)

##                 mpg cyl disp  hp drat    wt  qsec vs am gear carb
## Mazda RX4      21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag  21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1

1.Điều kiện VÀ: có thể sử dụng dấu “,”, hoặc “&” để ngăn cách các điều kiện với nhau:

mtcars %>%
  filter(mpg >= 21 & cyl == 6)

##    mpg cyl disp  hp drat    wt  qsec vs am gear carb
## 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## 3 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1

Tương đương với:

mtcars %>%
  filter(mpg >= 21, cyl == 6)

##    mpg cyl disp  hp drat    wt  qsec vs am gear carb
## 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## 3 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1

So sánh với subset(): subset chỉ cho phép dùng dầu “&” để ngăn các các điều kiện VÀ với nhau:

mtcars %>%
  subset(mpg >= 21 & cyl == 6)

##                 mpg cyl disp  hp drat    wt  qsec vs am gear carb
## Mazda RX4      21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag  21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1

Giá trị nằm trong một khoảng [a, b] có thể được lấy ra bằng 2 cách 1) biến >= a & biến <= b; 2) between(biến, a, b). Trong cách 1) chúng ta sử dụng điều kiện VÀ, cách 2 chúng ta sử dụng hàm between của dplyr để thay cho >= và <=.

mtcars %>%
  filter(mpg %>% between(19, 21))

##    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 2 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## 3 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## 4 19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2
## 5 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6

Tương đương với:

mtcars %>%
  filter(mpg >= 19 & mpg <= 21)

##    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 2 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## 3 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## 4 19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2
## 5 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6

2.Điều kiện HOẶC: dùng dấu “|” để ngăn cách các điều kiện với nhau, tương tự với subset()

mtcars %>%
  filter(mpg >= 21 | cyl == 6)

##     mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## 3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
## 4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## 5  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
## 6  24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
## 7  22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
## 8  19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## 9  17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## 10 32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
## 11 30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
## 12 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
## 13 21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
## 14 27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
## 15 26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
## 16 30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2
## 17 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
## 18 21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2

mtcars %>%
  subset(mpg >= 21 | cyl == 6)

##                 mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## Mazda RX4      21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## Datsun 710     22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
## Hornet 4 Drive 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## Valiant        18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
## Merc 240D      24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
## Merc 230       22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
## Merc 280       19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## Merc 280C      17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## Fiat 128       32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
## Honda Civic    30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
## Toyota Corolla 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
## Toyota Corona  21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
## Fiat X1-9      27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
## Porsche 914-2  26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
## Lotus Europa   30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2
## Ferrari Dino   19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
## Volvo 142E     21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2

Khi điều kiện HOẶC là chuỗi các giá trị rời rạc áp dụng cho cùng một trường, chúng ta có thể làm ngắn gọn hơn với cấu trúc “%in%” thay vì cấu phải liệt kê tất cả các điều kiện đơn lẻ và ngăn cách nhau bởi dấu “|”:

mtcars %>%
 filter(carb == 4 | carb == 3 | carb == 1)

##     mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## 3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
## 4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## 5  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
## 6  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
## 7  19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## 8  17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## 9  16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
## 10 17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3
## 11 15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3
## 12 10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4
## 13 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4
## 14 14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4
## 15 32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
## 16 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
## 17 21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
## 18 13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4
## 19 27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
## 20 15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4

Tương đương với:

mtcars %>%
  filter(carb %in% c(1, 3, 4))

##     mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## 3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
## 4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## 5  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
## 6  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
## 7  19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## 8  17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## 9  16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
## 10 17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3
## 11 15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3
## 12 10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4
## 13 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4
## 14 14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4
## 15 32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
## 16 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
## 17 21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
## 18 13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4
## 19 27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
## 20 15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4

Với hàm subset():

mtcars %>%
  subset(carb %in% c(1, 3, 4))

##                      mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
## Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
## Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
## Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## Merc 280C           17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## Merc 450SE          16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
## Merc 450SL          17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3
## Merc 450SLC         15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3
## Cadillac Fleetwood  10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4
## Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4
## Chrysler Imperial   14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4
## Fiat 128            32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
## Toyota Corolla      33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
## Toyota Corona       21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
## Camaro Z28          13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4
## Fiat X1-9           27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
## Ford Pantera L      15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4

Hàm slice() cho phép người dùng lấy dữ liệu dựa vào vị trí của dòng dữ liệu. Khái niệm dòng của dữ liệu thường không được áp dụng với dữ liệu bảng biểu có quan hệ (relational database) do khái niệm về tên (vị trí) của dòng dữ liệu không được đề cập (áp dụng với loại dữ liệu bảng biểu này). Trong R, dữ liệu được xác định rõ ràng thứ tự dòng, do đó slice() được sử dụng để xác định vị trí này.

mtcars %>%
  slice(c(1, 3, 5, 7)) # liệt kê các dòng thứ 1, 3, 5, 7

##    mpg cyl disp  hp drat   wt  qsec vs am gear carb
## 1 21.0   6  160 110 3.90 2.62 16.46  0  1    4    4
## 2 22.8   4  108  93 3.85 2.32 18.61  1  1    4    1
## 3 18.7   8  360 175 3.15 3.44 17.02  0  0    3    2
## 4 14.3   8  360 245 3.21 3.57 15.84  0  0    3    4

mtcars %>%
  slice(.$cyl == 4) # liệt kê các dòng có giá trị bằng 4

##    mpg cyl disp  hp drat   wt  qsec vs am gear carb
## 1   NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA
## 2   NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA
## 3   21   6  160 110  3.9 2.62 16.46  0  1    4    4
## 4   NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA
## 5   NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA
## 6   NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA
## 7   NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA
## 8   21   6  160 110  3.9 2.62 16.46  0  1    4    4
## 9   21   6  160 110  3.9 2.62 16.46  0  1    4    4
## 10  NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA
## 11  NA  NA   NA  NA   NA   NA    NA NA NA   NA   NA

mtcars %>%
  slice(row_number() == 1) # liệt kê giá trị dòng 1

##   mpg cyl disp  hp drat   wt  qsec vs am gear carb
## 1  21   6  160 110  3.9 2.62 16.46  0  1    4    4

mtcars %>%
  slice(order(.$qsec) %>% head) # sắp xếp lại dữ liệu mtcars theo cột qsec sau đó lấy 6 dòng dữ liệu (có giá trị qsec cao nhất)

##    mpg cyl disp  hp drat   wt  qsec vs am gear carb
## 1 15.8   8  351 264 4.22 3.17 14.50  0  1    5    4
## 2 15.0   8  301 335 3.54 3.57 14.60  0  1    5    8
## 3 13.3   8  350 245 3.73 3.84 15.41  0  0    3    4
## 4 19.7   6  145 175 3.62 2.77 15.50  0  1    5    6
## 5 14.3   8  360 245 3.21 3.57 15.84  0  0    3    4
## 6 21.0   6  160 110 3.90 2.62 16.46  0  1    4    4

3.3 Sắp xếp dữ liệu

Ngoài việc lọc dữ liệu có điều kiện, chúng ta cũng thường xuyên thực hiện việc sắp xếp dữ liệu theo một trật tự nhất định nào đó khi xem dữ liệu. Hàm arrange() hỗ trợ công việc này.

mtcars %>%
  arrange(mpg, cyl, disp)

##     mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1  10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4
## 2  10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4
## 3  13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4
## 4  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
## 5  14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4
## 6  15.0   8 301.0 335 3.54 3.570 14.60  0  1    5    8
## 7  15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3
## 8  15.2   8 304.0 150 3.15 3.435 17.30  0  0    3    2
## 9  15.5   8 318.0 150 2.76 3.520 16.87  0  0    3    2
## 10 15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4
## 11 16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
## 12 17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3
## 13 17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## 14 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
## 15 18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
## 16 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## 17 19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2
## 18 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
## 19 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 20 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## 21 21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2
## 22 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## 23 21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
## 24 22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
## 25 22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
## 26 24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
## 27 26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
## 28 27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
## 29 30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
## 30 30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2
## 31 32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
## 32 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1

Trong ví dụ trên, dữ liệu mtcars sẽ được sắp xếp theo thứ tự từ thấp lên cao cho lần lượt các cột mpg, cyl và disp với thứ tự ưu tiên tương ứng. Hàm arrange() có điểm tương đồng với hàm order() trong R base, nhưng hàm order() chỉ áp dụng cho vector và áp dụng cho 1 vector tại một thời điểm.

mtcars[order(mtcars$mpg, decreasing =  T),]

##                      mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## Toyota Corolla      33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
## Fiat 128            32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
## Honda Civic         30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
## Lotus Europa        30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2
## Fiat X1-9           27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
## Porsche 914-2       26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
## Merc 240D           24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
## Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
## Merc 230            22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
## Toyota Corona       21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
## Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
## Volvo 142E          21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2
## Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## Ferrari Dino        19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
## Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
## Pontiac Firebird    19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2
## Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
## Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
## Merc 280C           17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
## Merc 450SL          17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3
## Merc 450SE          16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
## Ford Pantera L      15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4
## Dodge Challenger    15.5   8 318.0 150 2.76 3.520 16.87  0  0    3    2
## Merc 450SLC         15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3
## AMC Javelin         15.2   8 304.0 150 3.15 3.435 17.30  0  0    3    2
## Maserati Bora       15.0   8 301.0 335 3.54 3.570 14.60  0  1    5    8
## Chrysler Imperial   14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4
## Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
## Camaro Z28          13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4
## Cadillac Fleetwood  10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4
## Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4

Hàm arrange() có thể được kết hợp với hàm desc() - hàm hỗ trợ để thể hiện dữ liệu theo chiều giảm dần (descending) để thực hiện được việc sắp xếp dữ liệu theo ý muốn của người dùng. Hàm desc() được dùng để bổ trợ cho hàm arrange().

mtcars %>%
  arrange(vs, gear %>% desc, carb) %>% # sắp xếp theo cột vs từ thấp đến cao, sau đó cột gear từ cao xuống thấp và cuối cùng là carb từ thấp đến cao.
  head

##    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1 26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
## 2 15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4
## 3 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
## 4 15.0   8 301.0 335 3.54 3.570 14.60  0  1    5    8
## 5 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 6 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4

Ví dụ khác của arrange():

mtcars %>%
  filter(mpg %>% between(19, 21)) %>%
  arrange(vs, gear %>% desc) # lấy dữ liệu từ mtcars thỏa mãn: mpg từ 19 đến 21, sau đó dữ liệu được sắp xếp lần lượt theo cột vs (tăng dần) và cột gear (giảm dần)

##    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
## 1 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
## 2 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
## 3 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
## 4 19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2
## 5 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4

3.4 Lấy dữ liệu theo trường thông tin mong muốn

Khi bạn cần lấy chi tiết các trường thông tin nào trong bảng dữ liệu, bạn có thể dùng hàm select() để nhặt chi tiết các trường. Hàm select() tương đồng với tham số select trong hàm subset().

mtcars %>%
  select(mpg, cyl, disp) %>%
  head

##                    mpg cyl disp
## Mazda RX4         21.0   6  160
## Mazda RX4 Wag     21.0   6  160
## Datsun 710        22.8   4  108
## Hornet 4 Drive    21.4   6  258
## Hornet Sportabout 18.7   8  360
## Valiant           18.1   6  225

Đối với subset():

mtcars %>%
  subset(select = c(mpg, cyl, disp)) %>%
  head

##                    mpg cyl disp
## Mazda RX4         21.0   6  160
## Mazda RX4 Wag     21.0   6  160
## Datsun 710        22.8   4  108
## Hornet 4 Drive    21.4   6  258
## Hornet Sportabout 18.7   8  360
## Valiant           18.1   6  225

Ngoài việc lấy chi tiết các cột (liệt kê từng cột) khi lấy dữ liệu trên 1 bảng, bạn có thể dùng một số hàm sau để hỗ trợ việc lấy trường dữ liệu được nhanh hơn:

    starts_with(“Ký tự là thông tin mong muốn”): các cột dữ liệu ccó tên hứa các ký tự mong muốn đứng ở đầu của tên, ví dụ:

iris %>%
  select(starts_with("Petal")) %>%
  head

##   Petal.Length Petal.Width
## 1          1.4         0.2
## 2          1.4         0.2
## 3          1.3         0.2
## 4          1.5         0.2
## 5          1.4         0.2
## 6          1.7         0.4

    ends_with(“Ký tự là thông tin mong muốn”): các cột dữ liệu có tên chứa các ký tự mong muốn ở cuối của tên, ví dụ:

iris %>%
  select(ends_with("Length")) %>%
  head

##   Sepal.Length Petal.Length
## 1          5.1          1.4
## 2          4.9          1.4
## 3          4.7          1.3
## 4          4.6          1.5
## 5          5.0          1.4
## 6          5.4          1.7

    contains(“Ký tự là thông tin mong muốn”): các cột dữ liệu có tên chứa chính xác các ký tự mong muốn ở bất kỳ vị trí nào của tên, ví dụ:

iris %>%
  select(contains("etal")) %>%
  head

##   Petal.Length Petal.Width
## 1          1.4         0.2
## 2          1.4         0.2
## 3          1.3         0.2
## 4          1.5         0.2
## 5          1.4         0.2
## 6          1.7         0.4

    matches(“Dạng ký tự là thông tin mong muốn”): các cột dữ liệu có tên chứa các ký tự có dạng ký tự mong muốn ở bất kỳ vị trí nào của tên, ví dụ:

iris %>%
  select(matches(".t.")) %>% # lấy tất cả các cột có tên chứa chữ t và có ký tự khác ở trước và sau (các ký tự chỉ chứa chữ t mà chữ t ở đâu hoặc cuối tên sẽ không được tính vào)
  head

##   Sepal.Length Sepal.Width Petal.Length Petal.Width
## 1          5.1         3.5          1.4         0.2
## 2          4.9         3.0          1.4         0.2
## 3          4.7         3.2          1.3         0.2
## 4          4.6         3.1          1.5         0.2
## 5          5.0         3.6          1.4         0.2
## 6          5.4         3.9          1.7         0.4

Ví dụ khác của select():

mtcars %>%
  filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
  select(disp, hp, drat, wt) %>%
  arrange(wt %>% desc) # lấy dữ liệu từ mtcars thỏa mãn: mpg <= 21  và cyl bằng 6 hoặc 8, sau đó chỉ lấy các trường disp, hp, drat và wt, dữ liệu cuối cùng được sắp xếp theo cân nặng (wt) từ cao xuống thấp

##     disp  hp drat    wt
## 1  460.0 215 3.00 5.424
## 2  440.0 230 3.23 5.345
## 3  472.0 205 2.93 5.250
## 4  275.8 180 3.07 4.070
## 5  400.0 175 3.08 3.845
## 6  350.0 245 3.73 3.840
## 7  275.8 180 3.07 3.780
## 8  275.8 180 3.07 3.730
## 9  360.0 245 3.21 3.570
## 10 301.0 335 3.54 3.570
## 11 318.0 150 2.76 3.520
## 12 225.0 105 2.76 3.460
## 13 360.0 175 3.15 3.440
## 14 167.6 123 3.92 3.440
## 15 167.6 123 3.92 3.440
## 16 304.0 150 3.15 3.435
## 17 351.0 264 4.22 3.170
## 18 160.0 110 3.90 2.875
## 19 145.0 175 3.62 2.770
## 20 160.0 110 3.90 2.620

Bây giờ bạn muốn đặt tên mới cho các trường mà bạn lấy từ một bảng dữ liệu, bạn có thể làm như sau:

mtcars %>%
  filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
  select(`miles per gallon` = mpg
         , cylinder = cyl
         , displacement = disp
         , `horse power` = hp
         , drat
         , weight = wt) %>%
  arrange(weight %>% desc)

##    miles per gallon cylinder displacement horse power drat weight
## 1              10.4        8        460.0         215 3.00  5.424
## 2              14.7        8        440.0         230 3.23  5.345
## 3              10.4        8        472.0         205 2.93  5.250
## 4              16.4        8        275.8         180 3.07  4.070
## 5              19.2        8        400.0         175 3.08  3.845
## 6              13.3        8        350.0         245 3.73  3.840
## 7              15.2        8        275.8         180 3.07  3.780
## 8              17.3        8        275.8         180 3.07  3.730
## 9              14.3        8        360.0         245 3.21  3.570
## 10             15.0        8        301.0         335 3.54  3.570
## 11             15.5        8        318.0         150 2.76  3.520
## 12             18.1        6        225.0         105 2.76  3.460
## 13             18.7        8        360.0         175 3.15  3.440
## 14             19.2        6        167.6         123 3.92  3.440
## 15             17.8        6        167.6         123 3.92  3.440
## 16             15.2        8        304.0         150 3.15  3.435
## 17             15.8        8        351.0         264 4.22  3.170
## 18             21.0        6        160.0         110 3.90  2.875
## 19             19.7        6        145.0         175 3.62  2.770
## 20             21.0        6        160.0         110 3.90  2.620

Nếu bạn muốn lấy toàn bộ tất cả các trường trong bảng dữ liệu và chỉ muốn thay đổi tên của một số cột, bạn có thể dùng hàm rename() để thay thế cho select() với những bảng dữ liệu có nhiều cột.

mtcars %>%
  filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
  rename(displacement = disp
         , `horse power` = hp
         , weight = wt) %>%
  arrange(weight %>% desc)

##     mpg cyl displacement horse power drat weight  qsec vs am gear carb
## 1  10.4   8        460.0         215 3.00  5.424 17.82  0  0    3    4
## 2  14.7   8        440.0         230 3.23  5.345 17.42  0  0    3    4
## 3  10.4   8        472.0         205 2.93  5.250 17.98  0  0    3    4
## 4  16.4   8        275.8         180 3.07  4.070 17.40  0  0    3    3
## 5  19.2   8        400.0         175 3.08  3.845 17.05  0  0    3    2
## 6  13.3   8        350.0         245 3.73  3.840 15.41  0  0    3    4
## 7  15.2   8        275.8         180 3.07  3.780 18.00  0  0    3    3
## 8  17.3   8        275.8         180 3.07  3.730 17.60  0  0    3    3
## 9  14.3   8        360.0         245 3.21  3.570 15.84  0  0    3    4
## 10 15.0   8        301.0         335 3.54  3.570 14.60  0  1    5    8
## 11 15.5   8        318.0         150 2.76  3.520 16.87  0  0    3    2
## 12 18.1   6        225.0         105 2.76  3.460 20.22  1  0    3    1
## 13 18.7   8        360.0         175 3.15  3.440 17.02  0  0    3    2
## 14 19.2   6        167.6         123 3.92  3.440 18.30  1  0    4    4
## 15 17.8   6        167.6         123 3.92  3.440 18.90  1  0    4    4
## 16 15.2   8        304.0         150 3.15  3.435 17.30  0  0    3    2
## 17 15.8   8        351.0         264 4.22  3.170 14.50  0  1    5    4
## 18 21.0   6        160.0         110 3.90  2.875 17.02  0  1    4    4
## 19 19.7   6        145.0         175 3.62  2.770 15.50  0  1    5    6
## 20 21.0   6        160.0         110 3.90  2.620 16.46  0  1    4    4

3.5 Lọc các giá trị duy nhất

Đôi khi, bạn chỉ muốn nhặt ra các giá trị duy nhất trong bảng dữ liệu. Để làm được việc này bạn có thể dùng hàm distinct(), hàm này tương đồng với hàm unique() trong R base.

mtcars %>%
  distinct(cyl) # lấy các giá trị duy nhất của cột dữ liệu cyl trong bảng mtcars

##   cyl
## 1   6
## 2   4
## 3   8

mtcars %>%
  distinct(vs, gear) # lấy các cặp dữ liệu duy nhất của 2 cột vs và gear trong bảng mtcars

##   vs gear
## 1  0    4
## 2  1    4
## 3  1    3
## 4  0    3
## 5  0    5
## 6  1    5

Tương đương với:

mtcars$cyl %>%
  unique

## [1] 6 4 8

mtcars[, c("vs", "gear")] %>%
  unique()

##                   vs gear
## Mazda RX4          0    4
## Datsun 710         1    4
## Hornet 4 Drive     1    3
## Hornet Sportabout  0    3
## Porsche 914-2      0    5
## Lotus Europa       1    5

Sự khác biệt rõ ràng nhất giữa distinct() và unique() mà các bạn có thể quan sát ở trên là với hàm unique(), chúng ta bắt buộc phải liệt kê rõ ràng vector hoặc bảng dữ liệu nào cần lấy danh sách giá trị duy nhất. Trong khi đó, với distinct() bạn có thể tìm danh sách các giá trị duy nhất của 1 cột, hoặc nhiều cột từ một bảng dữ liệu nào đó.
3.6 Tạo mới trường dữ liệu

Trong quá trình xử lý dữ liệu, rất nhiều lúc bạn muốn tạo thêm các trường dữ liệu mới (trường dữ liệu phát sinh) dựa vào công thức có liên quan đến các trường dữ liệu hiện tại (business rules). Hàm mutate() được sử dụng để làm công việc này. Trong R base, chúng ta cũng có thể thực hiện được yêu cầu này với hàm transform(), tuy nhiên với năng lực có phần hạn chế hơn, chúng ta sẽ đi qua ví dụ để làm rõ ý này.

mtcars %>%
  select(mpg) %>%
  mutate(kpg = mpg * 1.61) %>%
  head

##    mpg    kpg
## 1 21.0 33.810
## 2 21.0 33.810
## 3 22.8 36.708
## 4 21.4 34.454
## 5 18.7 30.107
## 6 18.1 29.141

Chúng ta vừa tạo ra cột dữ liệu mới có tên kpg (km per gallon) và được tính dựa vào trường mpg với công thức kpg=mpg∗1.61

. Dữ liệu nhận về sẽ là 2 cột dữ liệu mpg và kmp tương ứng. Bạn có thể làm điều tương tự với transform():

mtcars %>%
  subset(select = mpg) %>%
  transform(kpg = mpg * 1.61) %>%
  head

##                    mpg    kpg
## Mazda RX4         21.0 33.810
## Mazda RX4 Wag     21.0 33.810
## Datsun 710        22.8 36.708
## Hornet 4 Drive    21.4 34.454
## Hornet Sportabout 18.7 30.107
## Valiant           18.1 29.141

Chúng ta có thể xử lý tương tự cho nhiều trường dữ liệu cùng lúc:

mtcars %>%
  select(mpg, wt) %>%
  mutate(kpg = mpg * 1.61
         , wt_kg = wt/2.2) %>%
  head

##    mpg    wt    kpg    wt_kg
## 1 21.0 2.620 33.810 1.190909
## 2 21.0 2.875 33.810 1.306818
## 3 22.8 2.320 36.708 1.054545
## 4 21.4 3.215 34.454 1.461364
## 5 18.7 3.440 30.107 1.563636
## 6 18.1 3.460 29.141 1.572727

mtcars %>%
  subset(select = c(mpg, wt)) %>%
  transform(kpg = mpg * 1.61
            , wt_kg = wt/2.2) %>%
  head

##                    mpg    wt    kpg    wt_kg
## Mazda RX4         21.0 2.620 33.810 1.190909
## Mazda RX4 Wag     21.0 2.875 33.810 1.306818
## Datsun 710        22.8 2.320 36.708 1.054545
## Hornet 4 Drive    21.4 3.215 34.454 1.461364
## Hornet Sportabout 18.7 3.440 30.107 1.563636
## Valiant           18.1 3.460 29.141 1.572727

Sự khác biệt giữa mutate() và transform() ở chỗ với mutate() chúng ta có thể tạo ra trường mới dựa vào trường mới được tạo cùng lúc, trong khi đó transform() không cho phép thực hiện điều này - transform() chỉ thực hiện được việc tạo cột mới dựa vào các trường đã được thiết lập trước trên bảng dữ liệu.

mtcars %>%
  select(mpg, qsec) %>%
  mutate(kpg = mpg * 1.61 # km per gallon
         , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
         , gqsec_km = 1/kpg * 1/4 # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km
         ) %>%
  head

##    mpg  qsec    kpg qsec_km    gqsec_km
## 1 21.0 16.46 33.810 26.5006 0.007394262
## 2 21.0 17.02 33.810 27.4022 0.007394262
## 3 22.8 18.61 36.708 29.9621 0.006810505
## 4 21.4 19.44 34.454 31.2984 0.007256052
## 5 18.7 17.02 30.107 27.4022 0.008303717
## 6 18.1 20.22 29.141 32.5542 0.008578978

Với transfrom() bạn chỉ có thể làm được như sau:

mtcars %>%
  select(mpg, qsec) %>%
  transform(kpg = mpg * 1.61 # km per gallon
         , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
         ) %>%
  transform(gqsec_km = 1/kpg * 1/4) %>% # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km) 
  head

##                    mpg  qsec    kpg qsec_km    gqsec_km
## Mazda RX4         21.0 16.46 33.810 26.5006 0.007394262
## Mazda RX4 Wag     21.0 17.02 33.810 27.4022 0.007394262
## Datsun 710        22.8 18.61 36.708 29.9621 0.006810505
## Hornet 4 Drive    21.4 19.44 34.454 31.2984 0.007256052
## Hornet Sportabout 18.7 17.02 30.107 27.4022 0.008303717
## Valiant           18.1 20.22 29.141 32.5542 0.008578978

Như vậy, với transform(), trường gqsec_km chỉ được tạo ra sau khi trường kpg đã được tạo ra.

Với những tình huống khi người dùng không muốn lấy các trường thông tin cũ mà chỉ muốn lấy các trường thông tin mới thì có thể sử dụng hàm transmute() với cấu trúc giống như hàm mutate.

mtcars %>%
  transmute(kpg = mpg * 1.61) %>%
  head

##      kpg
## 1 33.810
## 2 33.810
## 3 36.708
## 4 34.454
## 5 30.107
## 6 29.141

mtcars %>%
  transmute(kpg = mpg * 1.61 # km per gallon
         , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
         , gqsec_km = 1/kpg * 1/4 # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km
         ) %>%
  head

##      kpg qsec_km    gqsec_km
## 1 33.810 26.5006 0.007394262
## 2 33.810 27.4022 0.007394262
## 3 36.708 29.9621 0.006810505
## 4 34.454 31.2984 0.007256052
## 5 30.107 27.4022 0.008303717
## 6 29.141 32.5542 0.008578978

3.7 Tổng hợp các chỉ tiêu dữ liệu

Trong quá trình xử lý dữ liệu, rất nhiều khi bạn phải tổng hợp dữ liệu theo các cách như: tính tổng, tính số dư bình quân, phương sai, tổng số lượng quan sát… Trong gói dplyr, bạn có thể sử dụng hàm summarise() để thực hiện công việc này.

iris %>%
  summarise(mean_SL = Sepal.Length %>% mean
            , total_SL = Sepal.Length %>% sum
            , sd_SL = Sepal.Length %>% sd
            )

##    mean_SL total_SL     sd_SL
## 1 5.843333    876.5 0.8280661

Phía trên chỉ là ví dụ đơn giản mà chúng ta có thể thay thế bằng hàm summary() trên R base, tuy nhiên, kết hợp giữa hàm summarise() và hàm group_by() trên dplyr sẽ cho chúng ta có cái nhìn về dữ liệu tổng hợp một cách đa chiều hơn. Hàm group_by() cho phép dữ liệu tổng hợp được gộp lại theo một hoặc nhiều trường thông tin khác nhau, giúp người phân tích có thể nhìn dữ liệu theo từ chiều riêng biệt hoặc gộp các chiều thông tin với nhau.

iris %>%
  group_by(Species) %>% # gộp theo chiều Species
  summarise(total_SL = Sepal.Length %>% sum # tính tổng giá trị
            , mean_SL = Sepal.Length %>% mean # tính số trung bình
            , count = n() # đếm số lượng quan sát 
            , standard_deviation = Sepal.Length %>% sd # tính độ lệch chuẩn
            )

## Source: local data frame [3 x 5]
## 
##      Species total_SL mean_SL count standard_deviation
##       <fctr>    <dbl>   <dbl> <int>              <dbl>
## 1     setosa    250.3   5.006    50          0.3524897
## 2 versicolor    296.8   5.936    50          0.5161711
## 3  virginica    329.4   6.588    50          0.6358796

Kết quả của chúng ta nhận được giờ đã ý nghĩa hơn rất nhiều khi các con số này được nhìn theo chiều về thực thể (Species), qua đó giúp chúng ta có đánh giá, so sánh giữa các thực thể với nhau.

data("UCBAdmissions") # dữ liệu về hồ sơ ứng tuyển của sinh viên trường UC Berkeley
str(UCBAdmissions) # kiểm tra cấu trúc dữ liệu của bảng

##  table [1:2, 1:2, 1:6] 512 313 89 19 353 207 17 8 120 205 ...
##  - attr(*, "dimnames")=List of 3
##   ..$ Admit : chr [1:2] "Admitted" "Rejected"
##   ..$ Gender: chr [1:2] "Male" "Female"
##   ..$ Dept  : chr [1:6] "A" "B" "C" "D" ...

admissions <- as.data.frame(UCBAdmissions) # quy đổi bảng dữ liệu về dạng data.frame (dữ liệu dạng bảng biểu)
admissions %>%
  group_by(Admit, Gender) %>%
  summarise(total_frq = Freq %>% sum
            , mean_frq = Freq %>% mean
            , sd_frq = Freq %>% sd
  )

## Source: local data frame [4 x 5]
## Groups: Admit [?]
## 
##      Admit Gender total_frq  mean_frq    sd_frq
##     <fctr> <fctr>     <dbl>     <dbl>     <dbl>
## 1 Admitted   Male      1198 199.66667 191.98403
## 2 Admitted Female       557  92.83333  69.10692
## 3 Rejected   Male      1493 248.83333  79.27274
## 4 Rejected Female      1278 213.00000 161.56609

Kết qủa trên cho chúng ta cái nhìn chi tiết hơn về tổng số lượng sinh viên ứng tuyển, số lượng sinh viên ứng tuyển bình quân và độ lệch chuẩn của số lượng sinh viên được chia theo giới tính và kết quả xét tuyển của trường (nhận, không nhận).
3.8 Ví dụ tổng hợp

Vừa rồi chúng ta đã đi qua những hàm cơ bản trong dplyr được sử dụng thường xuyên trong quá trình xử lý dữ liệu. Giờ chúng ta sẽ cùng đi qua một ví dụ tổng hợp hơn để cùng nhau áp dụng các kiến thức đã học được. Chúng ta sẽ sử dụng dữ liệu về các khoản vay của khách hàng để làm ví dụ tổng hợp cho phần này.

# Tải dữ liệu lên môi trường R
loan <- read.csv("C:/Users/ddpham/Downloads/FactLoan.csv")
names(loan) <- tolower(names(loan)) # đổi tên cột về dạng chữ thường
head(loan)

##   cust_no currency branch_id  pro_name due_days balance
## 1 2200675      VND   VN10176 Household        5  128250
## 2 2856443      VND   VN10307  Mortgage        2     500
## 3 2791801      VND   VN10166  Mortgage       29   40986
## 4 2625376      VND   VN10250 Household        8  239500
## 5 2845801      VND   VN10120  Mortgage       10  112666
## 6 3375077      VND   VN10114  Mortgage        3   29297

Một số thông tin cơ bản về dữ liệu dư nợ:

    cust_no: mã khách hàng

    currency: loại tiền vay

    branch_id: mã chi nhánh của khách hàng

    pro_name: tên sản phẩm khách hàng sử dụng (ví dụ: mortgage: là sản phẩm về mua nhà, đất với các khoản vay của KH được sử dụng cho mục đích này)

    due_days: số ngày khách hàng nợ chưa trả được gốc và lãi của khoản vay

    balance: tổng số dư nợ của khách hàng tại thời điểm tính toán

Với dữ liệu về dư nợ của khách hàng, các bạn có một số công việc cần làm sau:

    Nhặt ra 10 dòng dữ liệu ngẫu nhiên của dữ liệu
    Lọc ra các giá trị duy nhất của chi nhánh (branch_id) và số lượng sản phẩm (pro_name)
    Tạo thêm trường thông tin liên quan đến nhóm nợ, trong đó Nhóm 1: nợ < 30 ngày; Nhóm 2: >= 30, < 60 ngày; Nhóm 3: >= 60, < 120 ngày; Nhóm 4: > 120, <= 360 ngày, Nhóm 5 > 360 ngày
    Lọc ra thông tin về khoản vay có gía trị > 5 triệu
    Tổng hợp dữ liệu theo nhóm nợ, theo tên sản phẩm về: số lượng khách hàng, tổng dư nợ và số lượng ngày quá hạn bình quân cho tất cả các khách hàng và cho các khách hàng có khoảng vay lớn hơn 30 triệu.

4 Các hàm nâng cao trong dplyr
4.1 Hàm điều kiện phân nhóm

Chắc hẳn trong quá trình phân tích và xử lý dữ liệu, chúng ta sẽ tạo thêm các trường mới hoặc tính toán dữ liệu dựa vào từng điều kiện khác nhau để đưa ra giá trị của trường hoặc cách tính cho dữ liệu. Ví dụ: nhóm tuổi của khách hàng (KH) được tính dựa vào độ tuổi trong các khoảng như: <= 18 tuổi sẽ là “nhóm 1”, từ 18-25 là “nhóm 2”, từ 25-35 là “nhóm 3”… hay xếp loại sinh viên dựa vào điểm số như < 5 là “kém”, từ 5-7 là “khá”, từ 7-9 là “giỏi”, từ 9-10 là “xuất sắc”. Hoặc trong kinh doanh, bạn muốn tính thưởng cho KH thì sẽ phải dùng nhiều công thức khác nhau như KH thuộc VIP sẽ nhân 1 tỷ lệ, KH medium 1 tỷ lệ khác, hay KH thông thường thì sẽ 1 tỷ lệ khác…. Chúng ta sẽ cùng đi qua một vài ví dụ để nắm được hàm xử dụng trong dpyr.

Trong dplyr, hàm case_when() được tạo ra cho những công việc như ở trên.

a <- data.frame(number = 1:20) # tạo một bảng dữ liệu có số thứ tự từ 1 đến 20
a$nhom1 <- case_when(
  a$number <= 5 ~ "nhom 1", # nhóm 1: số từ 1 đến 5
  a$number > 5 & a$number <= 10 ~ "nhom 2", # nhóm 2: số từ 6 đến 10
  a$number > 10 & a$number <= 15 ~ "nhom 3", # nhóm 3: số từ 11 đến 15
  TRUE ~ "nhom 4" # các số còn lại
)

Lưu ý: với case_when, chúng ta không thể áp dụng pipe operator cho một bảng dữ liệu như các hàm khác và áp dụng với một trường dữ liệu trong bảng. chỉ cho vector.

Ví dụ trên chúng ta cũng có thể làm trong R base theo cách sau:

a$nhom2[a$number <= 5] <- "nhom 1"
a$nhom2[a$number > 5 & a$number <= 10] <- "nhom 2"
a$nhom2[a$number > 10 & a$number <= 15] <- "nhom 3"
a$nhom2[a$number > 15] <- "nhom 4"
a

##    number  nhom1  nhom2
## 1       1 nhom 1 nhom 1
## 2       2 nhom 1 nhom 1
## 3       3 nhom 1 nhom 1
## 4       4 nhom 1 nhom 1
## 5       5 nhom 1 nhom 1
## 6       6 nhom 2 nhom 2
## 7       7 nhom 2 nhom 2
## 8       8 nhom 2 nhom 2
## 9       9 nhom 2 nhom 2
## 10     10 nhom 2 nhom 2
## 11     11 nhom 3 nhom 3
## 12     12 nhom 3 nhom 3
## 13     13 nhom 3 nhom 3
## 14     14 nhom 3 nhom 3
## 15     15 nhom 3 nhom 3
## 16     16 nhom 4 nhom 4
## 17     17 nhom 4 nhom 4
## 18     18 nhom 4 nhom 4
## 19     19 nhom 4 nhom 4
## 20     20 nhom 4 nhom 4

Chúng ta có thể kết hợp case_when() và mutate() (hoặc transmute()) để lấy dữ liệu được như mong muốn. Tuy nhiên, chúng ta vẫn cần lưu ý là sẽ cần dùng dấu chấm (“.”) để truyền biến vào trong hàm case_when(). Ví dụ sau sẽ làm rõ ý của câu trên.

a %>%
  mutate(number
         , group = case_when(.$number <= 5 ~ "nhom 1" # number không được hiểu là cột dữ liệu của x, trừ khi chúng ta dùng "." làm đại diện cho x để được truyền vào hàm case_when() thông qua pipe operator.
                     , .$number > 5 & .$number <= 10 ~ "nhom 2"
                     , .$number > 10 & .$number <= 15 ~ "nhom 3"
                     , TRUE ~ "nhom 4")
         )

##    number  nhom1  nhom2  group
## 1       1 nhom 1 nhom 1 nhom 1
## 2       2 nhom 1 nhom 1 nhom 1
## 3       3 nhom 1 nhom 1 nhom 1
## 4       4 nhom 1 nhom 1 nhom 1
## 5       5 nhom 1 nhom 1 nhom 1
## 6       6 nhom 2 nhom 2 nhom 2
## 7       7 nhom 2 nhom 2 nhom 2
## 8       8 nhom 2 nhom 2 nhom 2
## 9       9 nhom 2 nhom 2 nhom 2
## 10     10 nhom 2 nhom 2 nhom 2
## 11     11 nhom 3 nhom 3 nhom 3
## 12     12 nhom 3 nhom 3 nhom 3
## 13     13 nhom 3 nhom 3 nhom 3
## 14     14 nhom 3 nhom 3 nhom 3
## 15     15 nhom 3 nhom 3 nhom 3
## 16     16 nhom 4 nhom 4 nhom 4
## 17     17 nhom 4 nhom 4 nhom 4
## 18     18 nhom 4 nhom 4 nhom 4
## 19     19 nhom 4 nhom 4 nhom 4
## 20     20 nhom 4 nhom 4 nhom 4

4.2 Hàm gộp các hai bảng dữ liệu

Trong R base, chúng ta thường dùng hàm merge() để gộp 2 bảng dữ liệu với nhau dựa vào 1 hoặc nhiều trường dữ liệu giống nhau. Trong gói dplyr, chúng ta có các hàm riêng biệt được sử dụng cho mục đích này, tuy thuộc vào kết quả đầu ra mà chúng ta mong muốn. Chúng ta sẽ đi qua 4 hàm cơ bản của dplyr và so sách với hàm merge() trong R base.

Giả sử chúng ta cần gộp 2 bảng dữ liệu x và y, các hàm để gộp 2 bảng dữ liệu sẽ như sau:

    Hàm inner_join(x, y…): được xử dụng để lấy tất cả dữ liệu chỉ có trên bảng x và y, ví dụ:

x <- data.frame(`StudentID` = seq(1, 10, 1), maths = c(10, 8, 7, 6, 7.8, 4, 7.7, 9, 9.5, 6.5))
y <- data.frame(`StudentID` = seq(2, 20, 2), physics = c(8, 9.5, 7.5, 6, 5.5, 6.5, 7.8, 8.2, 8, 7.5))
x %>%
  inner_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, lấy các dòng dữ liệu mà 2 bảng cùng có.

##   StudentID maths physics
## 1         2   8.0     8.0
## 2         4   6.0     9.5
## 3         6   4.0     7.5
## 4         8   9.0     6.0
## 5        10   6.5     5.5

Tương đương với hàm merge():

x %>%
  merge(y, by = "StudentID", all = F) # tham số all = F/FALSE (hoặc T/TRUE): có lấy toàn bộ dữ liệu của 2 bảng hay không, F/FALSE sẽ chỉ lấy dữ liệu có trên cả 2 bảng.

##   StudentID maths physics
## 1         2   8.0     8.0
## 2         4   6.0     9.5
## 3         6   4.0     7.5
## 4         8   9.0     6.0
## 5        10   6.5     5.5

    Hàm full_join(x, y…): lấy dữ liệu có cả trên bảng x, y, ví dụ:

x %>%
  full_join(y, by = "StudentID") # gộp 2 bảng dữ liệu a và b, dùng trường StudentID để map 2 bảng với nhau, lấy tất cả dữ liệu của 2 bảng

##    StudentID maths physics
## 1          1  10.0      NA
## 2          2   8.0     8.0
## 3          3   7.0      NA
## 4          4   6.0     9.5
## 5          5   7.8      NA
## 6          6   4.0     7.5
## 7          7   7.7      NA
## 8          8   9.0     6.0
## 9          9   9.5      NA
## 10        10   6.5     5.5
## 11        12    NA     6.5
## 12        14    NA     7.8
## 13        16    NA     8.2
## 14        18    NA     8.0
## 15        20    NA     7.5

Các giá trị về điểm toán (maths) sẽ trả về NA cho các StudentID không tồn tại trên bảng y và ngược lại cho bảng x với các giá trị điểm vật lý (physics) của các StudentID không tồn tại trên bảng x.

Tương đương với hàm merge():

x %>%
  merge(y, by = "StudentID", all = T) # ngược lại với ví dụ trên về merge(), tham số all chuyển về T/TRUE để lấy dữ liệu trên cả 2 bảng

##    StudentID maths physics
## 1          1  10.0      NA
## 2          2   8.0     8.0
## 3          3   7.0      NA
## 4          4   6.0     9.5
## 5          5   7.8      NA
## 6          6   4.0     7.5
## 7          7   7.7      NA
## 8          8   9.0     6.0
## 9          9   9.5      NA
## 10        10   6.5     5.5
## 11        12    NA     6.5
## 12        14    NA     7.8
## 13        16    NA     8.2
## 14        18    NA     8.0
## 15        20    NA     7.5

    Hàm left_join(x, y…): lấy dữ liệu chỉ có trên bảng x, ví dụ:

x %>%
  left_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, chỉ lấy dữ liệu có trên bảng x

##    StudentID maths physics
## 1          1  10.0      NA
## 2          2   8.0     8.0
## 3          3   7.0      NA
## 4          4   6.0     9.5
## 5          5   7.8      NA
## 6          6   4.0     7.5
## 7          7   7.7      NA
## 8          8   9.0     6.0
## 9          9   9.5      NA
## 10        10   6.5     5.5

Với các StudentID không có giá trị trên bảng y, cột physics sẽ trả về giá trị NA

Tương đương với merge():

x %>%
  merge(y, by = "StudentID", all.x = T) # tham số all.x = T/TRUE: tương đương với việc chỉ lấy toàn bộ dữ liệu trên bảng x

##    StudentID maths physics
## 1          1  10.0      NA
## 2          2   8.0     8.0
## 3          3   7.0      NA
## 4          4   6.0     9.5
## 5          5   7.8      NA
## 6          6   4.0     7.5
## 7          7   7.7      NA
## 8          8   9.0     6.0
## 9          9   9.5      NA
## 10        10   6.5     5.5

    Hàm right_join(x, y…): lấy dữ liệu chỉ có trên bảng y, ví dụ:

x %>%
  right_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, chỉ lấy dữ liệu có trên bảng y

##    StudentID maths physics
## 1          2   8.0     8.0
## 2          4   6.0     9.5
## 3          6   4.0     7.5
## 4          8   9.0     6.0
## 5         10   6.5     5.5
## 6         12    NA     6.5
## 7         14    NA     7.8
## 8         16    NA     8.2
## 9         18    NA     8.0
## 10        20    NA     7.5

Với các StudentID không có giá trị trên bảng x, cột maths sẽ trả về giá trị NA

Tương đương với merge():

x %>%
  merge(y, by = "StudentID", all.y = T) # tham số all.y = T/TRUE: tương đương với việc chỉ lấy toàn bộ dữ liệu trên bảng y

##    StudentID maths physics
## 1          2   8.0     8.0
## 2          4   6.0     9.5
## 3          6   4.0     7.5
## 4          8   9.0     6.0
## 5         10   6.5     5.5
## 6         12    NA     6.5
## 7         14    NA     7.8
## 8         16    NA     8.2
## 9         18    NA     8.0
## 10        20    NA     7.5

Trong trường hợp cột dữ liệu dùng để map có tên khác nhau, cấu trúc câu lệnh có thể khác đi một chút:

names(x)[1] <- "StudentID1"
names(y)[1] <- "StudentID2"
x %>%
  inner_join(y, by = c("StudentID1" = "StudentID2")) # tương tự cho các hàm khác trong dplyr

##   StudentID1 maths physics
## 1          2   8.0     8.0
## 2          4   6.0     9.5
## 3          6   4.0     7.5
## 4          8   9.0     6.0
## 5         10   6.5     5.5

Lưu ý: khi tên cột cần map giữa 2 bảng khác nhau thì kết quả đầu ra sẽ chỉ thể hiện tên của bảng x. Các trường còn lại sẽ được giữ nguyên tên

Tương đương với merge():

x %>%
  merge(y, by.x = "StudentID1", by.y = "StudentID2") 

##   StudentID1 maths physics
## 1          2   8.0     8.0
## 2          4   6.0     9.5
## 3          6   4.0     7.5
## 4          8   9.0     6.0
## 5         10   6.5     5.5

lưu ý: với merge(), khi chúng ta không bổ sung tham số về kết quả đầu ra sẽ lấy trên 1 trong 2 bảng hoặc cả 2 bảng (all; all.x; all.y), hàm sẽ mặc định chỉ lấy dữ liệu có trên cả 2 bảng - tương đương với all = F/FAlSE

Nếu 2 bảng dữ liệu cần nhiều hơn một cột dữ liệu để map được dữ liệu giữa 2 bảng với nhau, chúng ta có thể làm như sau:

x$UniversityID1 <- c(paste('00', seq(1, 9, 1), sep = ""), '010')
y$UniversityID2 <- c(paste('00', seq(2, 8, 2), sep = ""), '011', paste('0', seq(30, 50, 5), sep = ""))

x %>%
  inner_join(y, by = c("StudentID1" = "StudentID2", "UniversityID1" = "UniversityID2"))

##   StudentID1 maths UniversityID1 physics
## 1          2     8           002     8.0
## 2          4     6           004     9.5
## 3          6     4           006     7.5
## 4          8     9           008     6.0

Nếu các cột dữ liệu chung có tên giống nhau, cấu trúc câu lệnh sẽ đơn giản hơn rất nhiều:

names(x)[1] = "StID"
names(y)[1] = "StID"
names(x)[3] = "UniID"
names(y)[3] = "UniID"
x %>%
  inner_join(y, by = c("StID", "UniID"))

##   StID maths UniID physics
## 1    2     8   002     8.0
## 2    4     6   004     9.5
## 3    6     4   006     7.5
## 4    8     9   008     6.0

Tương tự như với hàm merge():

names(x)[1] = "StID1"
names(y)[1] = "StID2"
names(x)[3] = "UniID1"
names(y)[3] = "UniID2"

x %>%
  merge(y, by.x = c("StID1", "UniID1"), by.y = c("StID2", "UniID2"))

##   StID1 UniID1 maths physics
## 1     2    002     8     8.0
## 2     4    004     6     9.5
## 3     6    006     4     7.5
## 4     8    008     9     6.0

names(x)[1] = "StID"
names(y)[1] = "StID"
names(x)[3] = "UniID"
names(y)[3] = "UniID"

x %>%
  merge(y, by = c("StID", "UniID"))

##   StID UniID maths physics
## 1    2   002     8     8.0
## 2    4   004     6     9.5
## 3    6   006     4     7.5
## 4    8   008     9     6.0

5 Ví dụ tổng hợp

Trong ví dụ này, chúng ta sẽ bổ sung thêm thông tin về chi nhánh (branch), và thông tin về khách hàng (customer) để biết thêm các chiều thông tin khác nhau của các khoản vay của khách hàng.

# Tải các loại dữ liệu cho bài giảng:
branch <- read.csv("C:/Users/ddpham/Downloads/DimBranch.csv")
customer <- read.csv("C:/Users/ddpham/Downloads/DimCustomer.csv")
head(branch)

##   BRANCH_ID AREA REGION
## 1   VN10114  R01    BAC
## 2   VN10115  R07  TRUNG
## 3   VN10115  R11    NAM
## 4   VN10116  R09  TRUNG
## 5   VN10116  R13    NAM
## 6   VN10117  R10    NAM

head(customer)

##   CUST_NO GENDER        BOD  PROVINCE
## 1 1000124 Female 1963-04-19 Khanh Hoa
## 2 1000329 Female 1988-07-13   Da Nang
## 3 1000384   Male 1992-07-14    Ha Noi
## 4 1000439   Male 1983-10-03 Binh Dinh
## 5 1000490 Female 1987-04-06    Ha Noi
## 6 1000552   Male 1965-11-07    Ha Noi

names(customer) <- tolower(names(customer)) # chuyển đổi chữ hoa sang chữ thường
names(branch) <- tolower(names(branch))

Một số thông tin cơ bản về dữ liệu:

    Branch: thông tin về chi nhánh

        BRANCH_ID: mã chi nhánh

        AREA: thông tin về vùng của chi nhánh, được chia là 13 vùng

        REGION: thông tin về miền của chi nhánh (3 miền)

    Customer: thông tin về khách hàng

        CUST_NO: mã số khách hàng

        GENDER: giới tính của khách hàng

        BOD: thông tin về ngày sinh của khách hàng

        PROVINCE: thông tin về nơi cư chú (tỉnh thành) của khách hàng

Với dữ liệu chúng ta có về dư nợ, về chi nhánh và thông tin về khách hàng, một số công việc mà chúng ta cần làm như sau:

    Tạo bảng dữ liệu có thông tin về khách hàng về giới tính, độ tuổi, nhóm tuổi, số dư nợ và nhóm nợ.(gợi ý: dựa vào thông tin trên 2 bảng loan và customer)
    Tổng hợp số liệu về tổng dư nợ, dư nợ trung bình, tổng số khách hàng theo giới tính, nhóm tuổi và nhóm nợ
    Vẽ đồ thì tổng hợp kết quả trên
    Tổng hợp dữ liệu về khách hàng về miền, giới tính, nhóm tuổi bao gồm tổng dư nợ, số dư trung bình và số lượng khách hàng
    Vẽ đồ thị tổng hợp kết quả trên

Chúng ta sẽ cùng nhau đi qua ví dụ 1, 2, 3. Các ví dụ 4 và 5, các bạn sẽ dành thời gian riêng của mình để tự nghiên cứu.

library(lubridate) # sử dụng gói lubridate để chuyển đổi dữ liệu dưới dạng date

## 
## Attaching package: 'lubridate'

## The following object is masked from 'package:base':
## 
##     date

customer$bod <- ymd(customer$bod)

# Câu 1: xử lý dữ liệu
loan_new <- loan %>%
  inner_join(customer, by = c("cust_no")) %>%
  mutate(age = Sys.Date() %>% difftime(bod, units = "days") %>% as.numeric %>% divide_by(365) %>% round(0)
         , ovd_group = case_when(.$due_days < 30 ~ "nhom 1"
                                 , .$due_days >= 30 & .$due_days < 60 ~ "nhom 2"
                                 , .$due_days >= 60 & .$due_days < 120 ~ "nhom 3"
                                 , .$due_days >= 120 & .$due_days < 360 ~ "nhom 4"
                                 , TRUE ~ "nhom 5"
            
                                )
  ) %>%
  mutate(age_group = case_when(.$age <= 18 ~ "nhom 1"
                                 , .$age > 18 & .$age <= 30 ~ "nhom 2"
                                 , .$age > 30 & .$age <= 45 ~ "nhom 3"
                                 , .$age > 45 & .$age <= 65 ~ "nhom 4"
                                 , TRUE ~ "nhom 5"
                               )
  ) %>%
  select(cust_no, gender, age, age_group, ovd_group, balance)

# Câu 2: tổng hợp dữ liệu
loan_sum <- loan_new %>%
  group_by(gender, age_group, ovd_group) %>%
  summarise(no_cust = n() # đến số lượng khách hàng
            , tot_bal = balance %>% sum
            , mean_bal = balance %>% mean
  )
  
# Câu 3: vẽ đồ thị dữ liệu tổng hợp
library(ggplot2)
head(loan_sum)

## Source: local data frame [6 x 6]
## Groups: gender, age_group [3]
## 
##   gender age_group ovd_group no_cust  tot_bal mean_bal
##   <fctr>     <chr>     <chr>   <int>    <int>    <dbl>
## 1 Female    nhom 2    nhom 1      95  9686017 101958.1
## 2 Female    nhom 2    nhom 3       2    47379  23689.5
## 3 Female    nhom 3    nhom 1     196 27392386 139757.1
## 4 Female    nhom 3    nhom 2       3   310967 103655.7
## 5 Female    nhom 3    nhom 3       1   286588 286588.0
## 6 Female    nhom 4    nhom 1      92 22199323 241297.0

loan_sum %>%
  ggplot(aes(no_cust, tot_bal)) +
  geom_point(aes(col = gender), size = 2) +
  labs(x = "Số lượng khách hàng", y = "Tổng dư nợ") 

