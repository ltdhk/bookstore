import React, { useEffect, useRef } from 'react';
import * as echarts from 'echarts';
import type { RevenueTrend } from '../../api/dashboard';

interface OrderTrendChartProps {
  data: RevenueTrend[];
}

const OrderTrendChart: React.FC<OrderTrendChartProps> = ({ data }) => {
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
    const orderCounts = data.map(item => item.orderCount);

    const option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'line',
        },
        backgroundColor: 'rgba(255, 255, 255, 0.95)',
        borderColor: '#e8e8e8',
        borderWidth: 1,
        textStyle: {
          color: '#262626',
        },
        formatter: (params: any) => {
          const param = params[0];
          return `<div style="font-weight: 600; margin-bottom: 4px;">${param.axisValue}</div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: ${param.color};"></span>
              <span style="flex: 1;">订单数:</span>
              <span style="font-weight: 600;">${param.value}</span>
            </div>`;
        },
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        top: 20,
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
      yAxis: {
        type: 'value',
        axisLine: {
          lineStyle: {
            color: '#e8e8e8',
          },
        },
        axisLabel: {
          color: '#8c8c8c',
        },
        splitLine: {
          lineStyle: {
            color: '#f0f0f0',
            type: 'dashed',
          },
        },
      },
      series: [
        {
          name: '订单数',
          type: 'line',
          smooth: true,
          data: orderCounts,
          symbol: 'circle',
          symbolSize: 8,
          itemStyle: {
            color: '#52c41a',
          },
          lineStyle: {
            width: 3,
          },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              {
                offset: 0,
                color: 'rgba(82, 196, 26, 0.2)',
              },
              {
                offset: 1,
                color: 'rgba(82, 196, 26, 0)',
              },
            ]),
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

  return <div ref={chartRef} style={{ width: '100%', height: '300px' }} />;
};

export default OrderTrendChart;
