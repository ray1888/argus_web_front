<template>
  <!-- <div v-show="show" class="charts" ref="chart">
                                                                                                      </div>  -->
  <div class="jkcharts" ref="chart" :style="{height: dataNames.length * 0.32 + 5 + 'rem'}">
  </div>
</template>

<script>
  // 监控的图表组件
  import echarts from 'echarts'
  import http from 'service/myhttp'
  import urls from 'service/url'
  import moment from 'moment'
  import simdate from 'service/simdate'
  import _ from 'lodash' //js操作库
  export default {
    name: 'jkcharts',
    props: {
      option: { //配置
        type: Object,
        default: function() {
          return {}
        }
      },
      date: { //传入日期时间
        type: Object,
        default: function() {
          return {
            start: simdate.day7_ago(),
            end: simdate.today()
          }
        }
      },
      reloadhz: { //刷新频率
        type: Number,
        default: 0
      },
      show: {
        type: Boolean,
        default: false
      }
    },
    data() {
      return {
        name: 'jkchart',
        myChart: {},
        zbdata: [], //指标数据数组
        dataNames: [], //数据名数组
        chartoption: {},
        // dataArry: [], //图表填充数据数组
        timer: null //定时器id
        // ytype:{}, //y轴样式
      }
    },
    computed: {
      myoption: function() {
        return _.cloneDeep(this.option)
      },
      datetime: function() {
        //日期时间（时间戳）
        return {
          start: moment(this.date.start).format('X'),
          end: moment(this.date.end).format('X')
        }
      },
    },
    watch: { //嵌套过深的对象无法监听除非深度监听 耗性能不推荐 不知是否是存在数组的问题 最好发新的整个对象过来
      myoption: function(value) {
        //监听option配置
        this.chartreload()
      },
      date: function(value) {
        // 日期时间
        this.chartreload()
      },
      reloadhz: function(val) {
        //刷新频率更改时
        this.refresh()
      },
      show: function(val) {
        // console.log(val)
        //显示时重置大小免得大小有问题
        this.myChart.resize()
      },
      '$store.state.fonsize': function(val) {
        //监听全局fonsize 比例变化
        // console.log(val)
        this.myChart.resize();
      }
      // chartwidth: function(val) {
      //   this.myChart.resize();
      // }
    },
    methods: {
      getjkdata: function(data) {



          if(Object.keys(this.chartoption).length > 0){
              data.loading = true;
          }else{
              data.loading = false;
          }
        //获取监控图表数据
        return new Promise((resolve, reject) => {
          http.get(urls.HQJKSJ, data).then(res => {
              resolve(res.data)
            },
            err => {
              reject(err)
            }
          )
        })
      },
      chartreload: function() {
        this.dataNames= [];
        //重新加载图表
        this.getchartdata(this.myoption).then(res => {
          //所有请求完成后
          // console.info('所有请求数据', res)
          this.initchart()
          this.myChart.resize();
        })
      },
      unit_change: function(value, yselect) {
        //单位转换
        let newval = value
        if (yselect == '' || yselect == null || typeof(yselect) === 'undefined') {
          yselect = 'left'
        }
        let yconfig = this.option.yconfig[yselect] //y轴配置
        if (yconfig.type != '' && yconfig.unit != '') {
          switch (yconfig.type) { //单位类型判断
            case '数值':
              switch (yconfig.unit) { //单位分级判断
                case '个':
                  newval = newval / 1
                  break;
                case '千':
                  newval = newval / 1000
                  break;
                case '万':
                  newval = newval / 10000
                  break;
                case '千万':
                  newval = newval / 10000000
                  break;
                default:
                  break;
              }
              break;
            case '数据':
              switch (yconfig.unit) { //单位分级判断
                case 'B(Bytes)':
                  newval = newval / 1
                  break;
                case 'K(KiloBytes)':
                  newval = newval / 1024
                  break;
                case 'M(MegaBytes)':
                  newval = newval / 1024 / 1024
                  break;
                case 'G(GigaBytes)':
                  newval = newval / 1024 / 1024 / 1024
                  break;
                default:
                  break;
              }
              break;
            case '比例':
              switch (yconfig.unit) { //单位分级判断
                case '十分之几':
                  break;
                case '百分之几':
                  break;
                case '千分之几':
                  break;
                case '万分之几':
                  break;
                default:
                  break;
              }
              break;
            case '时间':
              switch (yconfig.unit) { //单位分级判断
                case '秒':
                  newval = newval / 1
                  break;
                case '分钟':
                  newval = newval / 60
                  break;
                case '小时':
                  newval = newval / 60 / 60
                  break;
                default:
                  break;
              }
              break;
            default:
              break;
          }
        }
        return newval
      },
        get_chart_type:function(name){
            //获取图表类型
            console.info('图类型',name)
            let type
            switch(name){
                case '折线图':
                    return 'line'
                    break;
                case '柱图':
                    return 'bar'
                    break;
                case '散点图':
                    return 'scatter'
                    break;
                default:
                    return ''
                    break;
            }
        },
        get_unit_string: function(yconfig) {
            //获取单位显示单位
            let unit = ''
            if (yconfig.type != '' && yconfig.unit != '') {
                switch (yconfig.type) { //单位类型判断
                    case '数值':
                        switch (yconfig.unit) { //单位分级判断
                            case '个':
                                unit = ''
                                break;
                            case '千':
                                unit = '千'
                                break;
                            case '万':
                                unit = '万'
                                break;
                            case '千万':
                                unit = '千万'
                                break;
                            default:
                                break;
                        }
                        break;
                    case '数据':
                        switch (yconfig.unit) { //单位分级判断
                            case 'B(Bytes)':
                                unit = 'B'
                                break;
                            case 'K(KiloBytes)':
                                unit = 'K'
                                break;
                            case 'M(MegaBytes)':
                                unit = 'M'
                                break;
                            case 'G(GigaBytes)':
                                unit = 'G'
                                break;
                            default:
                                break;
                        }
                        break;
                    case '比例':
                        switch (yconfig.unit) { //单位分级判断
                            case '十分之几':
                                unit = '%'
                                break;
                            case '百分之几':
                                unit = '%'
                                break;
                            case '千分之几':
                                unit = '%'
                                break;
                            case '万分之几':
                                unit = '%'
                                break;
                            default:
                                break;
                        }
                        break;
                    case '时间':
                        switch (yconfig.unit) { //单位分级判断
                            case '秒':
                                unit = 's'
                                break;
                            case '分钟':
                                unit = 'm'
                                break;
                            case '小时':
                                unit = 'h'
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
                }
            }
            // console.info('单位显示',unit)
            return unit
        },
      getparsedata: function(data, yselect) {
        //获取解析成数组后的数据(data:数据 , yselect:y轴选择)
        let onedata = []
        for (let key in data) {
          let value = data[key]
          //遍历获取key（时间）value(值)
          // console.info('时间', simdate.TMDTime(moment.unix(key)))
          let dataitem = [simdate.TMDTime(moment.unix(key)), this.unit_change(value)] //数据项
          onedata.push(dataitem) //填充一个数据组
        }
        return onedata
      },
        getchartdata: function(option) {
            //获取图表数据
            let xnzbs = option.xnzbs //性能指标
            let reques_arry = [] //请求数组
            xnzbs.forEach((item) => { //遍历查询所有指标
                let tags = ''
                if (item.tag.length > 0) {
                    tags = '{' //所有tag组成的对象字符串
                    item.tag.forEach((tag, index) => {
                        if (tag.key != '') {
                            tags = tag.key + '=' + (tag.value == '' ? '*' : tag.value)
                            // if (index + 1 < item.tag.length) {
                            //   tags = tags + tag.key + '=' + (tag.value == '' ? '*' : tag.value) + ','
                            // } else {
                            //   tags = tags + tag.key + '=' + (tag.value == '' ? '*' : tag.value) + '}'
                            // }
                        }
                        let qygz = '' //取样规则
                        if (item.qytime != '' && item.qytimed != '' && item.qyfun != '') {
                            qygz = '' + item.qytime + item.qytimed + '-' + item.qyfun + ':' //取样规则
                            // console.log(item)
                        }
                        let data = {
                            start: this.datetime.start, //开始时间
                            end: this.datetime.end, //结束时间
                            m: item.aggfun + ':' + qygz + item.zbname + '{' + tags + '}' //查询规则
                        }
                        let caozuo = this.getjkdata(data) //请求操作
                        caozuo.then(res => {
                            //一个个指标获取数据
                            //console.info('数据', res)
                            if (tag.value != '*') {
                                //如果配置不是所有(把数据写在每个tag里)
                                if (res.length > 0) {
                                    tag.data = this.getparsedata(res[0].dps, item.yselect)
                                } else {
                                    tag.data = []
                                }
                            } else {
                                //配置是所有
                                res.forEach(item => {
                                    //遍历所有数据
                                    item.dps = this.getparsedata(item.dps, item.yselect)
                                })
                                tag.data = res
                            }
                        })
                        reques_arry.push(caozuo)
                    })
                } else {
                    let qygz = '' //取样规则
                    if (item.qytime != '' && item.qytimed != '' && item.qyfun != '') {
                        qygz = '' + item.qytime + item.qytimed + '-' + item.qyfun + ':' //取样规则
                        // console.log(item)
                    }
                    let data = {
                        start: this.datetime.start, //开始时间
                        end: this.datetime.end, //结束时间
                        m: item.aggfun + ':' + qygz + item.zbname + '{' + tags + '}' //查询规则
                    }
                    let caozuo = this.getjkdata(data) //请求操作
                    caozuo.then(res => {
                        //一个个指标获取数据
                        console.info('数据', res)
                        //配置是所有
                        res.forEach(item => {
                            //遍历所有数据
                            item.dps = this.getparsedata(item.dps)
                        })
                        item.data = res
                    })
                    reques_arry.push(caozuo)
                }
            })
            return Promise.all(reques_arry)
        },
      initchart: function() {
        this.dataNames= [];
        //初始化图表
        let series = [] //指标图表配置数组
        this.myoption.xnzbs.forEach((zb, zbindex) => {
          //遍历所有指标配置
          if (zb.tag.length > 0) { //如果有配置分组标签
            zb.tag.forEach((onetag, tagindex) => {
              //遍历指标配置所有分组标签
              if (onetag.value != '*') {
                //如果不是所有主机
                let confiname
                if (zb.xlname != '' && zb.xlname != null && typeof(zb.xlname) != 'undefined') {
                  //如果有别名
                  confiname = zb.xlname //配置的数据名（指标加主机）
                } else {
                  confiname = zb.zbname //配置的数据名（指标加主机）
                }
                confiname = confiname + '(' + onetag.value + ')' //数据名（指标加主机）
                //遍历指标主机数据组
                this.dataNames.push(confiname) //填充数据名数组
                //数据指标名等于某指标名 然后导入指标当前配置
                series.push({
                  name: confiname,
                  type: this.get_chart_type(this.myoption.type),
                    barGap:'-100%',
                  itemStyle: {
                    normal: {
                      show: false
                    },
                    emphasis: {
                      show: true
                    },
                  },
                  // symbolSize:0,
                  showSymbol: false,
                  // smooth:true,
                  sampling: 'average',
                  yAxisIndex: zb.yselect == 'right' ? 1 : 0, //y轴位置0左1右
                  // stack: '总量',
                  // areaStyle: {
                  //   normal: {}
                  // },
                  data: onetag.data //数据点数据
                })
              } else {
                //所有主机
                onetag.data.forEach(item => {
                  //遍历数据
                  let confiname
                  if (zb.xlname != '' && zb.xlname != null && typeof(zb.xlname) != 'undefined') {
                    //如果有别名
                    confiname = zb.xlname //配置的数据名（指标加主机）
                  } else {
                    confiname = zb.zbname //配置的数据名（指标加主机）
                  }
                  confiname = confiname + '(' + item.tags[onetag.key] + ')' //数据名（指标加主机）
                  //遍历指标主机数据组
                  this.dataNames.push(confiname) //填充数据名数组
                  series.push({
                    name: confiname,
                    type: this.get_chart_type(this.myoption.type),
                      barGap:'-100%',
                    itemStyle: {
                      normal: {
                        show: false
                      },
                      emphasis: {
                        show: true
                      },
                    },
                    // symbolSize:0,
                    showSymbol: false,
                    // smooth:true,
                    sampling: 'average',
                    yAxisIndex: zb.yselect == 'right' ? 1 : 0, //y轴位置0左1右
                    // stack: '总量',
                    // areaStyle: {
                    //   normal: {}
                    // },
                    data: item.dps //数据点数据
                  })
                })
              }
            })
          } else {
            //没有设置主机则聚合
            let confiname
            if (zb.xlname != '' && zb.xlname != null && typeof(zb.xlname) != 'undefined') {
              //如果有别名
              confiname = zb.xlname //配置的数据名（指标加主机）
            } else {
              confiname = zb.zbname //配置的数据名（指标加主机）
            }
            //遍历指标主机数据组
            this.dataNames.push(confiname) //填充数据名数组
            //数据指标名等于某指标名 然后导入指标当前配置
            series.push({
              name: confiname,
              type: this.get_chart_type(this.myoption.type),
                barGap:'-100%',
              itemStyle: {
                normal: {
                  show: false
                },
                emphasis: {
                  show: true
                },
              },
              // symbolSize:0,
              showSymbol: false,
              // smooth:true,
              sampling: 'average',
              yAxisIndex: zb.yselect == 'right' ? 1 : 0, //y轴位置0左1右
              // stack: '总量',
              // areaStyle: {
              //   normal: {}
              // },
              data: zb.data[0].dps //数据点数据
            })
          }
        })

        var dataNamesLength = this.dataNames.length;
        // console.log('dataNamesLength', this.dataNames)
        // console.log('series', series)
        var percent = 20 + dataNamesLength*3 + '%';
        this.chartoption = {
          // title: {
          //   text: '堆叠区域图'
          // },
          tooltip: {
            trigger: 'axis',
            // formatter:'{a}:{c}',
            position: ['0%', '50%'],
            axisPointer: {
              type: 'cross',
              label: {
                backgroundColor: '#6a7985'
              }
            }
          },
          // axisLine:{
          //   lineStyle:{
          //     color:'#fff'
          //   }
          // },
          nameTextStyle:{
            color:'#fff'
          },
          legend: {
            // type:'scroll',
            orient:'vertical',
            // padding:[10, 0, 20, 0],
            data: this.dataNames,
           textStyle: {
                color: '#fff',
                fontSize:12,
            },
            // padding: [0,0,140,0]
            // bottom:20
          },
          // toolbox: {
          //   feature: {
          //     saveAsImage: {}
          //   }
          // },
          grid: {
            top:percent,
            left: '3%',
            right: '0',
            bottom: '3%',
            containLabel: true
          },
          xAxis: [{
            type: 'time',
              minInterval: 0,
              maxInterval: 3600 * 24 * 1000,
            nameTextStyle:{
              color:'red'
            },
            axisLabel: {
              color:'white'
            },
             boundaryGap: true,
          }],
          yAxis: [{
              name: this.myoption.yconfig.left.type,
              type: 'value',
              axisLabel: {
                formatter: '{value}' + this.get_unit_string(this.myoption.yconfig.left),
                color:'white'
              }
            },
            {
              name: this.myoption.yconfig.right.type,
              type: 'value',
              axisLabel: {
                formatter: '{value}' + this.get_unit_string(this.myoption.yconfig.right),
                color:'white'
              }
            }
          ],
          series: series
        }
        this.myChart.setOption(this.chartoption)
        this.myChart.resize()
      },
      refresh: function() {
        //定时刷新
        if (this.reloadhz) {
          //判断是否有设频率
          // console.log(this.reloadhz)
          if (this.timer) { //判断之前是否设了定时器
            clearInterval(this.timer)
          }
          this.timer = setInterval(() => {
            this.chartreload()
          }, this.reloadhz)
        } else {
          if (this.timer) {
            clearInterval(this.timer)
            this.timer = null
          }
        }
      }
    },
    mounted() {
      //组件挂载后
      let chart = this.$refs.chart
      this.myChart = echarts.init(chart);
      this.chartreload()
      // console.info('组件', this)
    },
    updated() {
      //数据更新后
      this.myChart.resize();
    },
    destroyed() {
      clearInterval(this.timer)
      this.timer = null;
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  .jkcharts {
/*    width: 100%;
    height: 100%;*/
  }
</style>
