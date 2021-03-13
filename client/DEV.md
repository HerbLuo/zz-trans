`POPUP`设置界面  
`WELCOME`欢迎及引导界面  
`BACKGROUND`后台服务  
`CONTENT`注入到用户访问的各界面中  

### 常规流程

---

#### 一.欢迎与引导模块

---

##### 1.注册及登陆

###### 界面
```
          ┌─────────────────┐
username  │                 │  
          └─────────────────┘
          ┌─────────────────┐
password  │                 │  
          └─────────────────┘  skip
           sign in | sign up    
           
       github | google | wechat
          
```
###### 流程
```
1 注册及登陆
  -> 1.1 用户名与密码
    -> 登陆
    -> 注册
  -> 1.2 第三方授权
  -> 1.3 跳过(临时账号)
  -> 1.4 直接关闭(此时，用户只能在Popup界面注册才能使用)
```


---
##### 2.其它信息录入
###### 界面
```
 step1: professional & professional words
   ☑ cs
     ☑ common ⦿ normal ◯ hai_ke_yi ◯ professional
     ☐ java ⦿ normal ◯ hai_ke_yi ◯ professional
     ☐ javascript ⦿ normal ◯ hai_ke_yi  professional
     ☐ typescript ⦿ normal ◯ hai_ke_yi ◯ professional
     ☐ rust ⦿ normal ◯ hai_ke_yi ◯ professional
     ... 
 step2: generally words
   1. firstly, choose a score that roughly represents your english level
   ◯300 ◯ 350 ⦿ 400(≈CET4) ◯ 500 ◯ 600(≈CET6) ◯ 800
   2. and then, there are three sets of words to fine-tune your english level
   
       group 1/3 
       aboard barn carve dock injection  mayor paste quote radius vertical ↺
       *      *    *     *    *          *     *     *     *      *         ☑ show translate
       words i know / all words
                 ◯30%      ⦿60%     ◯70%              ◯90%
                             
                               ( next group )
       
       your final score: 400
   
```
###### 流程
```
2 其它信息录入
  -> 2.1 专业及专业词汇
    -> 2.1.1 

  -> 2.2 通用词汇(未选专业词汇时，这里不能展开)
    -> 2.2.1 选择一个能大致代表你的英语水平的分数
      -> 2.2.1.1 然后，这里有三组词汇可以大致微调你的分数(20%低一级词汇, 50%当前级别词汇, 30%下一级词汇，另外过滤调所有简单和一般的专业词汇)
        -> 如果选的是50%及以下
          -> 下一组直接展示翻译信息(因为语境中的单词更好理解)
        -> 否则
          -> 默认隐藏翻译
```
---
  
















