<template>
    <div class="monitorView">
        <section class="header">
            <div class="time_div" v-if="false">
                <div v-for="(val,index) in shelfTimes" :class="{'active':(navTimeIndex === index)}" @click="navClick(val,index)">{{val.label}}</div>
            </div>
            <div class="inputTime_div">{{dateTimeString}}</div>
        </section>
        <section class="chart_box">
            <h3>{{viewname}}</h3>
            <ul>
                <li v-for="chart in chartList">
                    <h4>{{chart.title}}</h4>
                    <jkchart :option="chart" :date="datetime" :reloadhz="reloadhz"></jkchart>
                </li>
            </ul>
        </section>
        <timeselect :show="show" @close="close" @submitClick="submitClick" :hzArry="hzArry" :datetime="datetime2"></timeselect>
    </div>
</template>
<script>
import urls from 'service/url'
import http from 'service/myhttp'
import simdate from 'service/simdate'
import { Indicator, Loadmore } from 'mint-ui';
import jkchart from 'components/jkcharts'
import timeselect from 'components/timeselect'
import { MessageBox } from 'mint-ui';

export default {
    name: 'monitorView',
    components: {
        jkchart,
        timeselect
    },
    data() {
        return {
        mo:function(e){e.preventDefault();},
        show:false,
        editTimeShow: false, //时间编辑弹窗显示
        shelfTimes: [ //快捷时间数据数组
          {
            label: '5分钟',
            value: simdate.min5_ago()
          },
          {
            label: '10分钟',
            value: simdate.min10_ago()
          },
          {
            label: '30分钟',
            value: simdate.min30_ago()
          },
          {
            label: '1小时',
            value: simdate.hour1_ago()
          },
          {
            label: '1天',
            value: simdate.day1_ago()
          },
        ],
        datetime: { //时间选择
          start: simdate.day7_ago(),
          end: simdate.today()
        },
        datetime2: { //时间选择
          start: simdate.day7_ago(),
          end: simdate.today()
        },
        dateTimeString:'',
        showdeftime: false, //自定义时间显示
        definedTime: { //自定义时间
          start: simdate.day7_ago(),
          end: simdate.today(),
          reloadhz: 0
        },
        reloadhz: 0, //刷新频率
        hzArry: [ //频率数组
          {
            label: 'OFF',
            value: 0
          },
          {
            label: '5秒',
            value: 5000
          },
          {
            label: '30秒',
            value: 30000
          },
          {
            label: '1分钟',
            value: 60000
          },
          {
            label: '5分钟',
            value: 300000
          },
          {
            label: '30分钟',
            value: 1800000
          }
        ],
        timeunits: [{ //时间单位选择
            label: '秒',
            value: 's'
          },
          {
            label: '分钟',
            value: 'm'
          },
          {
            label: '小时',
            value: 'h'
          },
          {
            label: '天',
            value: 'd'
          },
          {
            label: '周',
            value: 'w'
          },
          {
            label: '月',
            value: 'n'
          },
          {
            label: '年',
            value: 'y'
          }
        ], //时间单位数组
        yselects: [ //y轴选择
          {
            label: '左y轴',
            value: 'left'
          },
          {
            label: '右y轴',
            value: 'right'
          }
        ],
        yconfig_types: ['数值', '数据', '比例', '时间'], //y轴配置（类型）
        viewid: '', //所属视图id
        viewname: '',
        zbList: [], //指标名列表
        funList: [], //函数接口地址数组
        value: '',
        dialogVisible: false, //监控图表显示隐藏
        monitoringInfo: { //监控数据
          navIndex: 0,
          navDataList: ['基本信息', '性能指标', '图表式样'],
          chartType: ['折线图', '柱图', '热力图', '散点图', '饼图', '雷达图', '树图', '表格'],
          chartTypeIndex: 0
        },
        edittype: '新增', //编辑窗口状态
        editChart: {
          //编辑图表（配置数据）
          nomalinfo: {
            //基础信息
            title: '', //图表标题
            type: '折线图', //图表类型
          },
          pfm_index: [
          ],
          ystyle: {
            //y轴样式配置
            left: {
              //左边y轴
              type: '', //类型
              unit: '' //单位
            },
            right: {
              //右边y轴
              type: '', //类型
              unit: '' //单位
            }
          }
        },
        chartList: [], //图表（配置）列表
        navTimeIndex:-1

        }
    },
    methods: {
        showTimeSelect:function(){
            this.show = true;
            this.datetime2 =  Object.assign({},this.datetime,{reloadhz:this.reloadhz});
            document.body.style.overflow = 'hidden';
            document.getElementById('html').style.overflow = 'hidden';
            document.addEventListener("touchmove",this.mo,false);
        },
        close:function(){
            this.show = false;
            document.body.style.overflow = 'visible';
            document.getElementById('html').style.overflow = 'visible';
            document.removeEventListener("touchmove",this.mo,false);        

        },
        submitClick:function(val){
            this.show = false;
            this.seleDefinedTime(val);
            document.body.style.overflow = 'visible';
            document.getElementById('html').style.overflow = 'visible';
            document.removeEventListener("touchmove",this.mo,false);        
        },
        navClick:function(val,index){
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;   
        this.datetime = {
          start: val.value,
          end: simdate.todayTime()
        }
        this.datetime2 = {
          start: val.value,
          end: simdate.todayTime()
        }
        this.dateTimeString = '最新' + val.label


           this.navTimeIndex = index; 
           this.updatedatetimeconfigs();
        },
      seleDefinedTime: function(obj) {
        //自定义时间选择
        this.datetime = {
          start: obj.start,
          end: obj.end
        }
        this.datetime2 = {
          start: obj.start,
          end: obj.end
        }
        this.reloadhz = obj.reloadhz;
        this.dateTimeString = '开始：' + simdate.TMDTime(this.datetime.start) + ' 结束：' + simdate.TMDTime(this.datetime.end)
      },
      updatedatetimeconfigs: function() {
        //更新视图数据的时间间隔配置
        return new Promise((resolve, reject) => {
          http.post(urls.GXSTSJPZ, {
            viewid: this.viewid, //视图id
            datatimeconfig: {
              viewid: this.viewid, //视图id
              start: this.datetime.start, //开始时间
              end: this.datetime.end, //结束时间
              datetext: this.dateTimeString, //时间描述文字
              reloadhz: this.reloadhz, //刷新频率
            },
            loading:true
          }).then(res => {
            // console.info('更新视图数据的时间间隔配置', res)
            resolve(res.data)
            this.$message({
              showClose: true,
              message: '操作成功',
              type: 'success'
            })
          }, err => {
            reject(err)
          })
        })
      },
      getQDTime: function(dateTimeString) {
        //获取快捷定义时间范围的时间
        let starttime
        switch (dateTimeString) {
          case '最新5分钟':
            starttime = simdate.min5_ago()
            this.navTimeIndex = 0;
            break;
          case '最新10分钟':
            starttime = simdate.min10_ago()
            this.navTimeIndex = 1;
            break;
          case '最新30分钟':
            starttime = simdate.min30_ago()
            this.navTimeIndex = 2;
            break;
          case '最新1小时':
            starttime = simdate.hour1_ago()
             this.navTimeIndex = 3;
            break;
          case '最新6小时':
            starttime = simdate.hour6_ago()
            this.navTimeIndex = 4;
            break;
          case '最新12小时':
            starttime = simdate.hour12_ago()
            this.navTimeIndex = 4;
            break;
          case '最新1天':
            starttime = simdate.day1_ago()
            this.navTimeIndex = 4;
            break;
          case '最新7天':
            starttime = simdate.day7_ago()
            break;
          case '最新15天':
            starttime = simdate.day15_ago()
            break;
          default:
            starttime = simdate.min5_ago()
            break;
        }
        return starttime
      },
      getdatetimeconfigs: function() {
        //获取视图数据的时间间隔配置
        return new Promise((resolve, reject) => {
          http.get(urls.HQSTSJPZ, {
            viewid: this.viewid
          }).then(res => {
            // console.info('获取视图数据的时间间隔配置', res)
            let dataoption
            let data = []
            let start
            let end
            if (res.data.length > 0) { //如果有数据
              data = res.data[0]
              this.dateTimeString = data.datetext
              if (this.dateTimeString.indexOf('最新') != -1) {
                //检索显示字符串（如果是快捷定义）
                start = this.getQDTime(this.dateTimeString)
                end = simdate.todayTime()
                dataoption = {
                  start: start,
                  end: end,
                }
                // console.info('时间选择', dataoption)
              } else {
                start = data.start
                end = data.end
                dataoption = {
                  start: start,
                  end: end,
                }
              }
              this.definedTime = Object.assign({}, {
                start: start,
                end: end,
              }, {
                'reloadhz': data.reloadhz
              })
              this.datetime = dataoption
              this.datetime2 = Object.assign({},dataoption);
              this.reloadhz = data.reloadhz
            }
            resolve(data)
          }, err => {
            reject(err)
          })
        })
      },
      searchart: function() {
        //查询图表配置数据
        http.get(urls.CXSTTB, {
          viewid: this.viewid,
        }).then(res => {
          let data = res.data
          // console.info('图表数据', data)
          this.chartList = data
          // console.info('图表数据', data)
        })
      }

    },
    mounted() {
      this.viewid = this.$route.query.viewid
      this.viewname = this.$route.query.name
      this.getdatetimeconfigs().then(data => {
        this.searchart()
      })
    }
}
</script>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="less" scoped>
.monitorView {
    padding:0 0.2rem;
}
.header {
    padding: 0rem 0.2rem 0.2rem;
    position: fixed;
    left: 0;
    top: 0;
    right: 0;
    background-color: white;
    z-index: 1000;
    .time_div {
        padding-top: 0.2rem;
        display: flex;
        justify-content: space-between;
        border-bottom: 0.01rem solid #d7d7d7;
        >div {
            font-size: 0.28rem;
            font-weight: bold;
            color: #777777;
           
        }
        .active {
            color:#7073e7; 
            border-bottom: 0.02rem solid #7073e7;
        }
    }
    .inputTime_div {
        margin-top: 0.2rem;
        height: 0.54rem;
        line-height: 0.54rem;
        text-align: left;
        padding-left: 5px;
        box-sizing: border-box;
        border: 0.01rem solid #dadada;
        border-radius: 0.1rem;
        background: url('../assets/time.png') no-repeat right 0.1rem center;
        background-size: 0.34rem 0.3rem; // background-position: right center;
        padding-right: 0.44rem;
    }
}
.chart_box {
    //margin-top: 1.63rem;
    margin-top: 0.94rem;
    background-color: #6daff8;
    padding: 0 0.1rem;
    border-radius: 0.1rem;
    >h3 {
        height: 0.62rem;
        line-height: 0.62rem;
        color: white;
        font-weight: bold;
        font-size: 0.28rem;
    }
    >ul {
        li {
            border-radius: 0.1rem;
            background-color: #4a76ad;
            margin-bottom: 0.1rem;
            &:last-child {
                margin-bottom: 0;
            }
            >h4 {
                height: 0.52rem;
                line-height: 0.52rem;
                color: white;
                font-weight: bold;
                font-size: 0.26rem;
            }
        }
    }
}
</style>