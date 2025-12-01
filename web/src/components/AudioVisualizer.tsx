import React, { useEffect, useRef, useState } from 'react'
import { motion } from 'framer-motion'
import { Radio, BarChart3, Activity } from 'lucide-react'
import { usePlayer } from '../contexts/PlayerContext'
import styles from './AudioVisualizer.module.css'

type VisualizerType = 'bars' | 'wave' | 'circle'

export const AudioVisualizer: React.FC = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const animationRef = useRef<number>()
  const [visualizerType, setVisualizerType] = useState<VisualizerType>('bars')
  
  const { isPlaying, analyserNode } = usePlayer()

  // Draw visualizer
  useEffect(() => {
    if (!isPlaying || !analyserNode || !canvasRef.current) {
      return
    }

    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const analyser = analyserNode
    const bufferLength = analyser.frequencyBinCount
    const dataArray = new Uint8Array(bufferLength)

    const draw = () => {
      analyser.getByteFrequencyData(dataArray)

      // Set canvas size
      const dpr = window.devicePixelRatio || 1
      const rect = canvas.getBoundingClientRect()
      canvas.width = rect.width * dpr
      canvas.height = rect.height * dpr
      ctx.scale(dpr, dpr)

      // Clear canvas
      ctx.fillStyle = 'rgba(0, 0, 0, 0.1)'
      ctx.fillRect(0, 0, rect.width, rect.height)

      if (visualizerType === 'bars') {
        drawBars(ctx, dataArray, rect.width, rect.height)
      } else if (visualizerType === 'wave') {
        drawWave(ctx, dataArray, rect.width, rect.height)
      } else if (visualizerType === 'circle') {
        drawCircle(ctx, dataArray, rect.width, rect.height)
      }

      animationRef.current = requestAnimationFrame(draw)
    }

    draw()

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current)
      }
    }
  }, [isPlaying, analyserNode, visualizerType])

  const drawBars = (
    ctx: CanvasRenderingContext2D,
    dataArray: Uint8Array,
    width: number,
    height: number
  ) => {
    const barCount = 64
    const barWidth = width / barCount
    const barSpacing = 2

    for (let i = 0; i < barCount; i++) {
      const value = dataArray[i * 2] || 0
      const barHeight = (value / 255) * height * 0.8
      const x = i * barWidth
      const y = height - barHeight

      // Create gradient
      const gradient = ctx.createLinearGradient(0, height, 0, y)
      gradient.addColorStop(0, '#a855f7')
      gradient.addColorStop(0.5, '#ec4899')
      gradient.addColorStop(1, '#f59e0b')

      ctx.fillStyle = gradient
      ctx.fillRect(x, y, barWidth - barSpacing, barHeight)

      // Add glow effect
      ctx.shadowBlur = 10
      ctx.shadowColor = '#a855f7'
    }
  }

  const drawWave = (
    ctx: CanvasRenderingContext2D,
    dataArray: Uint8Array,
    width: number,
    height: number
  ) => {
    ctx.lineWidth = 3
    ctx.strokeStyle = '#a855f7'
    ctx.shadowBlur = 10
    ctx.shadowColor = '#a855f7'

    ctx.beginPath()
    const sliceWidth = width / dataArray.length
    let x = 0

    for (let i = 0; i < dataArray.length; i++) {
      const v = dataArray[i] / 255.0
      const y = (v * height) / 2 + height / 2

      if (i === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }

      x += sliceWidth
    }

    ctx.lineTo(width, height / 2)
    ctx.stroke()

    // Add gradient fill
    ctx.lineTo(width, height)
    ctx.lineTo(0, height)
    ctx.closePath()

    const gradient = ctx.createLinearGradient(0, 0, 0, height)
    gradient.addColorStop(0, 'rgba(168, 85, 247, 0.3)')
    gradient.addColorStop(1, 'rgba(168, 85, 247, 0)')
    ctx.fillStyle = gradient
    ctx.fill()
  }

  const drawCircle = (
    ctx: CanvasRenderingContext2D,
    dataArray: Uint8Array,
    width: number,
    height: number
  ) => {
    const centerX = width / 2
    const centerY = height / 2
    const radius = Math.min(width, height) / 3
    const barCount = 128

    for (let i = 0; i < barCount; i++) {
      const value = dataArray[i] || 0
      const barHeight = (value / 255) * radius * 0.8
      const angle = (i / barCount) * Math.PI * 2

      const x1 = centerX + Math.cos(angle) * radius
      const y1 = centerY + Math.sin(angle) * radius
      const x2 = centerX + Math.cos(angle) * (radius + barHeight)
      const y2 = centerY + Math.sin(angle) * (radius + barHeight)

      // Create gradient
      const gradient = ctx.createLinearGradient(x1, y1, x2, y2)
      gradient.addColorStop(0, '#a855f7')
      gradient.addColorStop(1, '#ec4899')

      ctx.strokeStyle = gradient
      ctx.lineWidth = 3
      ctx.beginPath()
      ctx.moveTo(x1, y1)
      ctx.lineTo(x2, y2)
      ctx.stroke()
    }

    // Draw center circle
    ctx.beginPath()
    ctx.arc(centerX, centerY, radius * 0.3, 0, Math.PI * 2)
    ctx.fillStyle = 'rgba(168, 85, 247, 0.2)'
    ctx.fill()
  }

  const toggleVisualizerType = () => {
    setVisualizerType((prev) => {
      if (prev === 'bars') return 'wave'
      if (prev === 'wave') return 'circle'
      return 'bars'
    })
  }

  return (
    <div className={styles.container}>
      <canvas ref={canvasRef} className={styles.canvas} />
      
      <motion.button
        className={styles.toggleButton}
        onClick={toggleVisualizerType}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        title="Change visualizer style"
      >
        {visualizerType === 'bars' && <BarChart3 size={20} />}
        {visualizerType === 'wave' && <Radio size={20} />}
        {visualizerType === 'circle' && <Activity size={20} />}
      </motion.button>

      {!isPlaying && (
        <div className={styles.overlay}>
          <Activity size={48} strokeWidth={1} />
          <p>Play music to see visualizer</p>
        </div>
      )}
    </div>
  )
}
