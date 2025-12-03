import React, { useEffect, useRef } from 'react';
import * as echarts from 'echarts';
import type { RevenueTrend } from '../../api/dashboard';

interface RevenueTrendChartProps {
  data: RevenueTrend[];
}

const RevenueTrendChart: React.FC<RevenueTrendChartProps> = ({ data }) => {
  const chartRef = useRef<HTMLDivElement>(null);
  const chartInstance = useRef<echarts.ECharts | null>(null);

  useEffect(() => {
    if (chartRef.current) {
      chartInstance.current = echarts.init(chartRef.current);
    }

    return () => {
      chartInstance.current?.dispose();
    };
  }, []);

  useEffect(() => {
    if (!chartInstance.current || !data || data.length === 0) return;

    const dates = data.map(item => item.date);
    const revenues = data.map(item => item.revenue);
    const orderCounts = data.map(item => item.orderCount);

    const option = {
      title: {
        text: '收益趋势',
        textStyle: {
          fontSize: 18,
          fontWeight: 600,
          color: '#262626',
        },
        left: 0,
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'cross',
          crossStyle: {
            color: '#999',
          },
        },
        backgroundColor: 'rgba(255, 255, 255, 0.95)',
        borderColor: '#e8e8e8',
        borderWidth: 1,
        textStyle: {
          color: '#262626',
        },
        formatter: (params: any) => {
          let result = `<div style="font-weight: 600; margin-bottom: 4px;">${params[0].axisValue}</div>`;
          params.forEach((param: any) => {
            const value = param.seriesName === '收益' ? `¥${param.value.toFixed(2)}` : param.value;
            result += `<div style="display: flex; align-items: center; gap: 8px;">
              <span style="display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: ${param.color};"></span>
              <span style="flex: 1;">${param.seriesName}:</span>
              <span style="font-weight: 600;">${value}</span>
            </div>`;
          });
          return result;
        },
      },
      legend: {
        data: ['收益', '订单数'],
        right: 0,
        top: 0,
        textStyle: {
          fontSize: 14,
        },
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        top: 60,
        containLabel: true,
      },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: dates,
        axisLine: {
          lineStyle: {
            color: '#e8e8e8',
          },
        },
        axisLabel: {
          color: '#8c8c8c',
        },
      },
      yAxis: [
        {
          type: 'value',
          name: '收益 (¥)',
          position: 'left',
          axisLine: {
            lineStyle: {
              color: '#e8e8e8',
            },
          },
          axisLabel: {
            formatter: '¥{value}',
            color: '#8c8c8c',
          },
          splitLine: {
            lineStyle: {
              color: '#f0f0f0',
              type: 'dashed',
            },
          },
        },
        {
          type: 'value',
          name: '订单数',
          position: 'right',
          axisLine: {
            lineStyle: {
              color: '#e8e8e8',
            },
          },
          axisLabel: {
            color: '#8c8c8c',
          },
          splitLine: {
            show: false,
          },
        },
      ],
      series: [
        {
          name: '收益',
          type: 'line',
          smooth: true,
          data: revenues,
          yAxisIndex: 0,
          symbol: 'circle',
          symbolSize: 8,
          itemStyle: {
            color: '#1890ff',
          },
          lineStyle: {
            width: 3,
          },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              {
                offset: 0,
                color: 'rgba(24, 144, 255, 0.2)',
              },
              {
                offset: 1,
                color: 'rgba(24, 144, 255, 0)',
              },
            ]),
          },
        },
        {
          name: '订单数',
          type: 'line',
          smooth: true,
          data: orderCounts,
          yAxisIndex: 1,
          symbol: 'circle',
          symbolSize: 8,
          itemStyle: {
            color: '#52c41a',
          },
          lineStyle: {
            width: 3,
          },
        },
      ],
    };

    chartInstance.current.setOption(option);

    const handleResize = () => {
      chartInstance.current?.resize();
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, [data]);

  return <div ref={chartRef} style={{ width: '100%', height: '400px' }} />;
};

export default RevenueTrendChart;
